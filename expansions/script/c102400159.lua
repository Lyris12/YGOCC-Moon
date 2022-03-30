--created & coded by Lyris, idea by LeonDuvall of Discord
--リリカル・ララバイ
local s,id,o=GetID()
function s.initial_effect(c)
	local gmg,gmgct,gfg,gfgct,iemc,smc,iet,selt,get_type,get_orig_type,get_prev_type_field=Duel.GetMatchingGroup,Duel.GetMatchingGroupCount,Duel.GetFieldGroup,Duel.GetFieldGroupCount,Duel.IsExistingMatchingCard,Duel.SelectMatchingCard,Duel.IsExistingTarget,Duel.SelectTarget,Card.GetType,Card.GetOriginalType,Card.GetPreviousTypeOnField
	Card.GetType=function(tc,scard,sumtype,p)
		local tpe=scard and get_type(tc,scard,sumtype,p) or get_type(tc)
		if tc==c then tpe=tpe|TYPE_SKILL&~TYPE_SPELL end
		return tpe
	end
	Card.GetOriginalType=function(tc)
		local tpe=get_orig_type(tc)
		if tc==c then tpe=tpe|TYPE_SKILL&~TYPE_SPELL end
		return tpe
	end
	Card.GetPreviousTypeOnField=function(tc)
		local tpe=get_prev_type_field(tc)
		if tc==c then tpe=tpe|TYPE_SKILL&~TYPE_SPELL end
		return tpe
	end
	Duel.GetFieldGroup=function(p,sloc,oloc)
		return gfg(p,sloc,oloc)-c
	end
	Duel.GetFieldGroupCount=function(p,sloc,oloc)
		return #(Duel.GetFieldGroup(p,sloc,oloc))
	end
	Duel.GetMatchingGroup=function(f,p,sloc,oloc,exc,...)
		if f==nil or f==aux.TRUE then return gfg(p,sloc,oloc)
		else return gmg(f,p,sloc,oloc,exc,table.unpack{...})-c end
	end
	Duel.GetMatchingGroupCount=function(f,p,sloc,oloc,exc,...)
		return #(Duel.GetMatchingGroup(f,p,sloc,oloc,exc,table.unpack{...}))
	end
	Duel.IsExistingMatchingCard=function(f,p,sloc,oloc,ct,exc,...)
		return Duel.GetMatchingGroupCount(f,p,sloc,oloc,exc,table.unpack{...})>=ct
	end
	Duel.SelectMatchingCard=function(sp,f,p,sloc,oloc,minc,maxc,exc,...)
		return Duel.GetMatchingGroup(f,p,sloc,oloc,exc,table.unpack{...}):Select(sp,minc,maxc,nil)
	end
	Duel.IsExistingTarget=function(f,p,sloc,oloc,ct,exc,...)
		local t={...}
		return iet(function(tc) return (not f or f(tc,table.unpack(t))) and (f==nil or f==aux.TRUE or tc~=c) end,p,sloc,oloc,ct,exc)
	end
	Duel.SelectTarget=function(sp,f,p,sloc,oloc,minc,maxc,exc,...)
		local t={...}
		return selt(sp,function(tc) return (not f or f(tc,table.unpack(t))) and (f==nil or f==aux.TRUE or tc~=c) end,p,sloc,oloc,minc,maxc,exc)
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e4:SetRange(LOCATION_DECK+LOCATION_HAND)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e4:SetOperation(function(e,tp)
		local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local hc=#hg
		Duel.Hint(HINT_CARD,0,id)
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
		if hc==0 or #g==0 then return end
		Duel.SendtoDeck(hg,nil,2,REASON_RULE)
		if c:IsPreviousLocation(LOCATION_HAND) then hc=hc+1 end
		Duel.ShuffleDeck(tp)
		for tc in aux.Next(g:RandomSelect(tp,math.min(hc,5))) do Duel.MoveSequence(tc,0) end
		Duel.Draw(tp,hc,REASON_RULE)
		Duel.Exile(c,REASON_RULE)
	end)
	c:RegisterEffect(e4)
end
function s.filter(c)
	local t=global_card_effect_table[c]
	if not t then return false end
	for _,e in ipairs(t) do if e:IsHasCategory(CATEGORY_SEARCH) then return true end end
	return false
end
