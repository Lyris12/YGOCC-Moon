--created & coded by Lyris, art from Shadowverse's "Lightning Blast"
--襲雷弾
local s,id,off=GetID()
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
		return gmg(f,p,sloc,oloc,exc,table.unpack{...})-c
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
		return iet(function(tc) return (not f or f(tc,table.unpack(t))) and tc~=c end,p,sloc,oloc,ct,exc)
	end
	Duel.SelectTarget=function(sp,f,p,sloc,oloc,minc,maxc,exc,...)
		local t={...}
		return selt(sp,function(tc) return (not f or f(tc,table.unpack(t))) and tc~=c end,p,sloc,oloc,minc,maxc,exc)
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_STARTUP)
	e4:SetRange(LOCATION_DECK)
	e4:SetOperation(function() Duel.Remove(c,POS_FACEUP,REASON_RULE) end)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.skillcon_skill)
	e1:SetOperation(s.skillop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetOperation(s.skillop2)
	c:RegisterEffect(e2)
end
function s.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end
function s.filter(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsLocation(LOCATION_GRAVE))
end
function s.skillop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==0 or not g:GetFirst():IsLocation(LOCATION_DECK) then return end
	Duel.ShuffleDeck(tp)
	Duel.RegisterFlagEffect(tp,1,RESET_CHAIN,0,1)
end
function s.cfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsSetCard(0x7c4) and c:IsDestructable()
end
function s.skillop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,1)==0 or Duel.GetFlagEffect(tp,id)>=3 then return end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if #g1==0 or #g2==0 or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end
	Duel.Hint(HINT_CARD,0,id)
	local g=g1:Select(tp,1,1,nil)+g2:Select(tp,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
