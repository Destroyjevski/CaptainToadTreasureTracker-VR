// SPDX-License-Identifier: GPL-3.0-only
// Local game-marker importer. No game data is included in this source.
// GX2 tiled-address mapping adapted from AboodXD's BFLIM Extractor addrlib.
// See licenses/Marker-Importer-GPL-3.0.txt and Marker-Importer-NOTICE.txt.
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.IO;
using System.Numerics;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace ToadMarkers {
public static class Importer {
    public const string Revision = "1";
    static void Require(bool ok, string message) { if (!ok) throw new InvalidDataException(message); }
    public static string HashFile(string path) {
        using (var sha = SHA256.Create()) using (var stream = File.OpenRead(path))
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
    }
    sealed class Reader {
        public byte[] D;
        public Reader(byte[] data) { D = data; }
        public void Check(int p, int n) { Require(p >= 0 && n >= 0 && (long)p + n <= D.Length, "Invalid model offset"); }
        public int U8(int p) { Check(p,1); return D[p]; }
        public int U16(int p) { Check(p,2); return (D[p]<<8)|D[p+1]; }
        public uint U32(int p) { Check(p,4); return ((uint)D[p]<<24)|((uint)D[p+1]<<16)|((uint)D[p+2]<<8)|D[p+3]; }
        public int Int(int p) { return checked((int)U32(p)); }
        public int Ptr(int p) { int n=unchecked((int)U32(p)); if(n==0)return 0; int v=checked(p+n); Check(v,1); return v; }
        public float F(int p) { return BitConverter.ToSingle(BitConverter.GetBytes(U32(p)),0); }
        public string S(int p) { Check(p,1); int end=p; while(end<D.Length && end-p<4096 && D[end]!=0)end++; Require(end<D.Length && end-p<4096,"Invalid name"); return Encoding.UTF8.GetString(D,p,end-p); }
        public List<KeyValuePair<string,int>> Group(int p) {
            var result=new List<KeyValuePair<string,int>>(); if(p==0)return result;
            int count=Int(p+4); Require(count<=4096,"Too many model entries");
            for(int i=0;i<count;i++) { int q=checked(p+24+i*16);result.Add(new KeyValuePair<string,int>(S(Ptr(q+8)),Ptr(q+12))); } return result;
        }
    }
    static byte[] Unpack(byte[] data) {
        var r=new Reader(data); if(data.Length<4 || Encoding.ASCII.GetString(data,0,4)!="Yaz0")return data;
        int size=r.Int(4); Require(size>0 && size<=64*1024*1024,"Unsupported archive size");
        var output=new byte[size]; int p=16, used=0;
        while(used<size) { int bits=r.U8(p++); for(int i=7;i>=0 && used<size;i--) {
            if((bits&(1<<i))!=0)output[used++]=(byte)r.U8(p++);
            else { int a=r.U8(p++),b=r.U8(p++),distance=((a&15)<<8)|b;int n=a>>4;
                n=n==0?r.U8(p++)+18:n+2;Require(distance<used && n<=size-used,"Invalid compressed archive");
                for(int k=0;k<n;k++) { output[used]=output[used-distance-1];used++; }
            }
        }} return output;
    }
    static Reader Model(string archive) {
        Require(new FileInfo(archive).Length<=64*1024*1024,"Archive too large");
        byte[] d=Unpack(File.ReadAllBytes(archive));var r=new Reader(d);
        Require(d.Length>=32 && Encoding.ASCII.GetString(d,0,4)=="SARC" && r.U16(6)==0xfeff,"Expected Wii U archive");
        int sfat=r.U16(4),start=r.Int(12);Require(r.S(sfat).StartsWith("SFAT"),"Missing archive table");
        int count=r.U16(sfat+6),entries=sfat+r.U16(sfat+4);Require(count<=4096,"Too many archive entries");
        for(int i=0;i<count;i++) { int q=entries+i*16,a=checked(start+r.Int(q+8)),b=checked(start+r.Int(q+12));r.Check(a,b-a);
            if(b-a>=4 && Encoding.ASCII.GetString(d,a,4)=="FRES") { byte[] model=new byte[b-a];Buffer.BlockCopy(d,a,model,0,model.Length);return new Reader(model); }
        } throw new InvalidDataException("No model found in archive");
    }
    sealed class Texture { public int W,H;public Vector4[] Pixels; }
    // Specialised 2D_THIN1 mapping for 64-bit BC1/BC4 blocks, one sample/slice.
    static int BlockAddress(int x,int y,int pitch,int swizzle) {
        int micro=(x&1)|((y&1)<<1)|((x&2)<<1)|((x&4)<<1)|((y&2)<<3)|((y&4)<<3);
        int pipe=((y>>3)^(x>>3))&1;
        int bank=(((y>>5)^(x>>3))&1)|((((y>>4)^(x>>4))&1)<<1);
        int bankPipe=(pipe|(bank<<1))^((swizzle>>8)&7);
        int offset=micro*8+(x/32+(pitch/32)*(y/16))*512;
        return ((bankPipe&1)<<8)|((bankPipe>>1)<<9)|(offset&255)|((offset&~255)<<3);
    }
    static Vector4 RGB565(int x) {return new Vector4(((x>>11)&31)*255/31,((x>>5)&63)*255/63,(x&31)*255/31,255);}
    static Texture DecodeTexture(Reader r,int p) {
        int w=r.Int(p+8),h=r.Int(p+12),format=r.Int(p+24)&255,pitch=r.Int(p+64),swizzle=r.Int(p+56);
        Require(w>0 && h>0 && w<=2048 && h<=2048 && r.Int(p+52)==4 && (format==0x31 || format==0x34),"Unsupported marker texture");
        int start=r.Ptr(p+0xb0),size=r.Int(p+36);r.Check(start,size);
        var t=new Texture { W=w,H=h,Pixels=new Vector4[w*h] };
        for(int by=0;by<(h+3)/4;by++)for(int bx=0;bx<(w+3)/4;bx++) {
            int off=BlockAddress(bx,by,pitch,swizzle);Require(off+8<=size,"Texture block out of range");int q=start+off;
            var colors=new Vector4[8];ulong codes=0;int bits;
            if(format==0x31) {
                int c0=r.U8(q)|(r.U8(q+1)<<8),c1=r.U8(q+2)|(r.U8(q+3)<<8);colors[0]=RGB565(c0);colors[1]=RGB565(c1);
                if(c0>c1) { colors[2]=(colors[0]*2+colors[1])/3;colors[3]=(colors[0]+colors[1]*2)/3; }
                else { colors[2]=(colors[0]+colors[1])/2; colors[3]=Vector4.Zero; }
                for(int j=0;j<4;j++)codes|=(ulong)r.U8(q+4+j)<<(j*8);bits=2;
            } else {
                int a=r.U8(q),b=r.U8(q+1);var v=new int[8];v[0]=a;v[1]=b;
                if(a>b)for(int j=2;j<8;j++)v[j]=((8-j)*a+(j-1)*b)/7;
                else { for(int j=2;j<6;j++)v[j]=((6-j)*a+(j-1)*b)/5;v[6]=0;v[7]=255; }
                for(int j=0;j<8;j++)colors[j]=new Vector4(v[j],v[j],v[j],255);
                for(int j=0;j<6;j++)codes|=(ulong)r.U8(q+2+j)<<(j*8);bits=3;
            }
            for(int i=0;i<16;i++) { int x=bx*4+i%4,y=by*4+i/4;int index=(int)((codes>>(i*bits))&((1UL<<bits)-1));
                if(x<w && y<h)t.Pixels[y*w+x]=colors[index]; }
        } return t;
    }
    static float Half(int n) { int s=(n&0x8000)==0?1:-1,e=(n>>10)&31,m=n&1023;Require(e!=31,"Nonfinite vertex value");return (float)(s*(e==0?m*Math.Pow(2,-24):(1024+m)*Math.Pow(2,e-25))); }
    static float Signed10(uint v) { int n=(int)(v&1023);return Math.Max(-1,(n>=512?n-1024:n)/511f); }
    static Vector4 Attribute(Reader r,int p,int format) {
        switch(format) {
            case 0x811:return new Vector4(r.F(p),r.F(p+4),r.F(p+8),0);
            case 0x80d:return new Vector4(r.F(p),r.F(p+4),0,0);
            case 0x808:return new Vector4(Half(r.U16(p)),Half(r.U16(p+2)),0,0);
            case 0x80f:return new Vector4(Half(r.U16(p)),Half(r.U16(p+2)),Half(r.U16(p+4)),Half(r.U16(p+6)));
            case 0x20b:uint n=r.U32(p);return new Vector4(Signed10(n),Signed10(n>>10),Signed10(n>>20),0);
            case 7:return new Vector4(r.U16(p)/65535f,r.U16(p+2)/65535f,0,0);
            case 4:return new Vector4(r.U8(p)/255f,r.U8(p+1)/255f,0,0);
            case 10:return new Vector4(r.U8(p)/255f,r.U8(p+1)/255f,r.U8(p+2)/255f,r.U8(p+3)/255f);
            case 0x100:return new Vector4(r.U8(p),0,0,0);
            default:throw new InvalidDataException("Unsupported vertex attribute");
        }
    }
    static Dictionary<string,Vector4[]> Attributes(Reader r,int p) {
        int count=r.Int(p+8),n=r.U8(p+4),buffers=r.Ptr(p+24),attrs=r.Ptr(p+16);Require(count>0 && count<=100000 && n<=32,"Invalid vertices");
        var result=new Dictionary<string,Vector4[]>();
        for(int i=0;i<n;i++) { int q=attrs+i*12;string name=r.S(r.Ptr(q));if(name!="_p0" && name!="_n0" && name!="_c0" && name!="_u0" && name!="_i0")continue;
            int buffer=buffers+r.U8(q+4)*24,stride=r.U16(buffer+12),start=r.Ptr(buffer+20)+r.U16(q+6),format=r.Int(q+8);var values=new Vector4[count];
            for(int j=0;j<count;j++)values[j]=Attribute(r,checked(start+j*stride),format);result.Add(name,values);
        }return result;
    }
    static Matrix4x4 Rotation(float x,float y,float z) { return Matrix4x4.CreateRotationX(x)*Matrix4x4.CreateRotationY(y)*Matrix4x4.CreateRotationZ(z); }
    static Matrix4x4[] Bones(Reader r,int model,out int[] indices) {
        int sk=r.Ptr(model+12),count=r.U16(sk+8),baseBone=r.Ptr(sk+20);Require(count>0 && count<=1024,"Invalid skeleton");var bones=new Matrix4x4[count];
        for(int i=0;i<count;i++) { int p=baseBone+i*64;var scale=Matrix4x4.CreateScale(r.F(p+20),r.F(p+24),r.F(p+28));Matrix4x4 rotation;
            if(r.U16(p+18)==1)rotation=Matrix4x4.CreateFromQuaternion(new Quaternion(r.F(p+32),r.F(p+36),r.F(p+40),r.F(p+44)));
            else rotation=Rotation(r.F(p+32),r.F(p+36),r.F(p+40));
            var m=scale*rotation*Matrix4x4.CreateTranslation(r.F(p+48),r.F(p+52),r.F(p+56));int parent=r.U16(p+6);
            if(parent!=65535) { Require(parent<i,"Invalid bone hierarchy");m=m*bones[parent]; } bones[i]=m;
        }
        int table=r.Ptr(sk+24),ic=r.U16(sk+10)+r.U16(sk+12);Require(ic<=4096,"Invalid bone table");indices=new int[ic];for(int i=0;i<ic;i++)indices[i]=r.U16(table+i*2);return bones;
    }
    sealed class Material { public Texture Tex;public Vector4 Tint=Vector4.One;public int U,V; }
    sealed class Mesh { public Vector3[] P,N;public Vector4[] C,UV;public int[] Faces;public Material Mat; }
    static List<Mesh> Load(Reader r,string name) {
        var textures=new Dictionary<string,Texture>();var textureOffsets=r.Group(r.Ptr(0x24));var meshes=new List<Mesh>();
        foreach(var model in r.Group(r.Ptr(0x20))) {
            int p=model.Value;int[] boneIds;var bones=Bones(r,p,out boneIds);var materials=new List<Material>();
            foreach(var material in r.Group(r.Ptr(p+24))) {
                int m=material.Value,n=r.U8(m+16),refs=r.Ptr(m+40);var mat=new Material();int selected=-1;
                for(int i=0;i<n;i++) { string tn=r.S(r.Ptr(refs+i*8));if(!tn.Contains("_alb"))continue;
                    if(!textures.ContainsKey(tn)) { int tp=0;foreach(var kv in textureOffsets)if(kv.Key==tn)tp=kv.Value;Require(tp!=0,"Missing model texture");textures.Add(tn,DecodeTexture(r,tp)); }
                    mat.Tex=textures[tn];selected=i;break;
                }
                if(mat.Tex==null)mat.Tex=new Texture{W=1,H=1,Pixels=new[]{new Vector4(255,255,255,255)}};
                int sampler=r.Ptr(m+44);uint reg=sampler!=0?r.U32(sampler+Math.Max(0,selected)*24):0;mat.U=(int)(reg&7);mat.V=(int)((reg>>3)&7);
                int parameters=r.Ptr(m+52),parameterData=r.Ptr(m+60);
                for(int i=0;i<r.U16(m+18);i++) { int q=parameters+i*20;if(r.S(r.Ptr(q+16))=="cDiffuseColor") { int t=parameterData+r.U16(q+2);mat.Tint=new Vector4(r.F(t),r.F(t+4),r.F(t+8),r.F(t+12)); } }
                materials.Add(mat);
            }
            foreach(var shape in r.Group(r.Ptr(p+20))) {
                if(name=="SwitchPull" && shape.Key.StartsWith("BodyEmpty__"))continue;
                int sp=shape.Value;var a=Attributes(r,r.Ptr(sp+32));Require(a.ContainsKey("_p0") && a.ContainsKey("_n0"),"Missing geometry");int count=a["_p0"].Length;
                var mesh=new Mesh{P=new Vector3[count],N=new Vector3[count],C=new Vector4[count],UV=new Vector4[count],Mat=materials[r.U16(sp+14)]};int skin=r.U8(sp+22);Require(skin<=1,"Unsupported skinning");
                for(int i=0;i<count;i++) {
                    int bi=skin==0?r.U16(sp+16):boneIds[(int)a["_i0"][i].X];Require(bi<bones.Length,"Invalid bone index");Matrix4x4 inv;Require(Matrix4x4.Invert(bones[bi],out inv),"Invalid bone transform");
                    var v=a["_p0"][i];mesh.P[i]=Vector3.Transform(new Vector3(v.X,v.Y,v.Z),bones[bi]);v=a["_n0"][i];mesh.N[i]=Vector3.TransformNormal(new Vector3(v.X,v.Y,v.Z),Matrix4x4.Transpose(inv));
                    mesh.C[i]=(a.ContainsKey("_c0")?a["_c0"][i]:Vector4.One)*mesh.Mat.Tint;mesh.UV[i]=a.ContainsKey("_u0")?a["_u0"][i]:Vector4.Zero;
                }
                int lod=r.Ptr(sp+36),format=r.Int(lod+4),total=r.Int(lod+8),ib=r.Ptr(r.Ptr(lod+20)+20),offset=r.Int(lod+24);
                Require(r.Int(lod)==4 && (format==4 || format==9) && total<=300000 && total%3==0,"Unsupported triangles");mesh.Faces=new int[total];
                for(int i=0;i<total;i++) { int ix=checked((format==4?r.U16(ib+i*2):r.Int(ib+i*4))+offset);Require(ix<count,"Vertex out of range");mesh.Faces[i]=ix; }meshes.Add(mesh);
            }
        } Require(meshes.Count>0 && meshes.Count<=128,"No supported shapes");return meshes;
    }
    static float Wrap(float f,int mode) {
        if(mode==0)return f-(float)Math.Floor(f);
        if(mode==1) { f=f-(float)Math.Floor(f/2)*2;return 1-Math.Abs(f-1); }
        if(mode==3)f=Math.Abs(f);return Math.Max(0,Math.Min(1,f));
    }
    static byte Byte(float value) {return (byte)Math.Max(0,Math.Min(255,value));}
    static Bitmap Render(List<Mesh> meshes,float yaw,float pitch,float roll) {
        const int size=768;var transform=Rotation(pitch*(float)Math.PI/180,yaw*(float)Math.PI/180,roll*(float)Math.PI/180);
        Vector3 lo=new Vector3(float.MaxValue),hi=new Vector3(float.MinValue);
        foreach(var m in meshes)for(int i=0;i<m.P.Length;i++) { m.P[i]=Vector3.Transform(m.P[i],transform);lo=Vector3.Min(lo,m.P[i]);hi=Vector3.Max(hi,m.P[i]);m.N[i]=Vector3.TransformNormal(m.N[i],transform); }
        var center=(lo+hi)*.5f;float extent=Math.Max(hi.X-lo.X,hi.Y-lo.Y);Require(!float.IsNaN(extent) && !float.IsInfinity(extent) && extent>0,"Invalid model bounds");float scale=size*.82f/extent;
        var pixels=new byte[size*size*4];var depth=new float[size*size];for(int i=0;i<depth.Length;i++)depth[i]=float.MinValue;
        var light=Vector3.Normalize(new Vector3(-.35f,.55f,1));
        foreach(var m in meshes) {
            for(int i=0;i<m.P.Length;i++) { var v=(m.P[i]-center)*scale;m.P[i]=new Vector3(v.X+size/2,size/2-v.Y,v.Z); }
            for(int i=0;i<m.Faces.Length;i+=3) {
                int ia=m.Faces[i],ib=m.Faces[i+1],ic=m.Faces[i+2];var a=m.P[ia];var b=m.P[ib];var c=m.P[ic];
                int xmin=Math.Max(0,(int)Math.Floor(Math.Min(a.X,Math.Min(b.X,c.X)))),xmax=Math.Min(size-1,(int)Math.Ceiling(Math.Max(a.X,Math.Max(b.X,c.X))));
                int ymin=Math.Max(0,(int)Math.Floor(Math.Min(a.Y,Math.Min(b.Y,c.Y)))),ymax=Math.Min(size-1,(int)Math.Ceiling(Math.Max(a.Y,Math.Max(b.Y,c.Y))));
                float den=(b.Y-c.Y)*(a.X-c.X)+(c.X-b.X)*(a.Y-c.Y);if(Math.Abs(den)<1e-10)continue;
                for(int y=ymin;y<=ymax;y++)for(int x=xmin;x<=xmax;x++) {
                    float wa=((b.Y-c.Y)*(x+.5f-c.X)+(c.X-b.X)*(y+.5f-c.Y))/den,wb=((c.Y-a.Y)*(x+.5f-c.X)+(a.X-c.X)*(y+.5f-c.Y))/den,wc=1-wa-wb;
                    int dest=y*size+x;float z=wa*a.Z+wb*b.Z+wc*c.Z;if(wa<-.00001 || wb<-.00001 || wc<-.00001 || z<=depth[dest])continue;
                    var uv=m.UV[ia]*wa+m.UV[ib]*wb+m.UV[ic]*wc;var tex=m.Mat.Tex;int tx=Math.Min(tex.W-1,(int)(Wrap(uv.X,m.Mat.U)*tex.W)),ty=Math.Min(tex.H-1,(int)(Wrap(uv.Y,m.Mat.V)*tex.H));
                    var color=tex.Pixels[ty*tex.W+tx]*(m.C[ia]*wa+m.C[ib]*wb+m.C[ic]*wc);if(color.W<=20)continue;
                    var normal=m.N[ia]*wa+m.N[ib]*wb+m.N[ic]*wc;float length=normal.Length();if(length>1e-10)normal/=length;
                    float shade=.45f+.55f*Math.Max(0,Math.Min(1,Vector3.Dot(normal,light)));int q=dest*4;
                    pixels[q]=Byte(color.Z*shade);pixels[q+1]=Byte(color.Y*shade);pixels[q+2]=Byte(color.X*shade);pixels[q+3]=Byte(color.W);depth[dest]=z;
                }
            }
        }
        using(var large=new Bitmap(size,size,PixelFormat.Format32bppArgb)) {
            var bits=large.LockBits(new Rectangle(0,0,size,size),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
            try { Marshal.Copy(pixels,0,bits.Scan0,pixels.Length); }finally {large.UnlockBits(bits);}
            var result=new Bitmap(256,256,PixelFormat.Format32bppArgb);
            using(var g=Graphics.FromImage(result)) {g.Clear(Color.Transparent);g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;g.DrawImage(large,new Rectangle(0,0,256,256));}return result;
        }
    }
    public static void Generate(string objectData,string output) {
        string[] models={"MarioHummer","Radish","SwitchPull","Coin"};string[] files={"stun-hammer.png","aim-radish.png","touch-switch.png","touch-coin.png"};
        Directory.CreateDirectory(output);
        for(int i=0;i<4;i++) { var reader=Model(Path.Combine(objectData,models[i]+".szs"));var meshes=Load(reader,models[i]);
            using(var image=Render(meshes,i==0?-15:-25,i==0?-65:15,i==0?-30:0))image.Save(Path.Combine(output,files[i]),ImageFormat.Png);
        }
    }
}
}