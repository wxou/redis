package com.gouyu.utils;

import com.gouyu.dto.MemberDTO;

public class MemberContext {
    private static final ThreadLocal<MemberDTO> tl = new ThreadLocal<>();

    public static void saveMember(MemberDTO member){
        tl.set(member);
    }

    public static MemberDTO getMember(){
        return tl.get();
    }

    public static void removeMember(){
        tl.remove();
    }
}
