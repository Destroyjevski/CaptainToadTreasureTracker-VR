#include "cemuvr/touch_preview.h"
#include <cstdlib>
#include <iostream>
#include <fstream>

#define CHECK(x) do { if(!(x)) { std::cerr<<"FAIL line "<<__LINE__<<": " #x "\n";std::exit(1); } } while(false)

int main(int argc,char** argv) {
    CHECK(cemuvr::makeTouchPreview(0).empty());
    CHECK(cemuvr::makeTouchPreview(4096).empty());
    for(unsigned size:{16,64,256,1024}) {
        const auto p=cemuvr::makeTouchPreview(size);
        CHECK(p.size()==size*size*4);
        unsigned visible=0,peak=0;
        for(unsigned y=0;y<size;++y)for(unsigned x=0;x<size;++x) {
            const auto at=(y*size+x)*4;
            const auto a=p[at+3];peak=(std::max)(peak,unsigned(a));visible+=a!=0;
            CHECK(a<=245); // Strong ring; centre and surroundings remain transparent.
            CHECK(a==p[(y*size+size-1-x)*4+3]);
            CHECK(a==p[((size-1-y)*size+x)*4+3]);
            if(x==0 || y==0 || x==size-1 || y==size-1)CHECK(a==0);
            if(!a)CHECK(!p[at] && !p[at+1] && !p[at+2]);
        }
        CHECK(visible>0 && visible<size*size/2 && peak>180);
        CHECK(p[((size/2)*size+size/2)*4+3]==0); // Open centre for precise aiming.
        if(size==256 && argc>1) {
            std::ofstream out(argv[1],std::ios::binary);
            out.write(reinterpret_cast<const char*>(p.data()),p.size());
            CHECK(out.good());
        }
    }
    CHECK(cemuvr::touchPreviewAngularSize>=0.05f);
    const auto texture=cemuvr::makeTouchPreview(256);
    unsigned legible=0;
    for(unsigned y=0;y<32;++y)for(unsigned x=0;x<32;++x) {
        float opacity=0,contrast=0;
        for(unsigned dy=0;dy<8;++dy)for(unsigned dx=0;dx<8;++dx) {
            const auto at=((y*8+dy)*256+x*8+dx)*4;
            const float a=texture[at+3]/255.f;
            opacity+=a/64.f;
            // Blue sky: the dark rim must remain discernible after filtering.
            contrast+=std::abs(float(texture[at+1])-160.f)*a/64.f;
        }
        if(opacity>0.4f && contrast>20.f)++legible;
    }
    CHECK(legible>=24);
    std::cout<<"PASS visual-only touch preview: RGBA, transparent centre/edges, contrasting ring, sizes\n";
}
