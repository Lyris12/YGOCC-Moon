--created by Moon Burst, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1166)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(SUMMON_TYPE_LINK)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(aux.linklimit)
	c:RegisterEffect(e4)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(id-3)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
function s.matfilter(c,codes)
	return codes[Card.GetLinkCode()] and c:IsAbleToDeckAsCost()
end
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local t={[id-3]=true,[id+8]=true,[id+5]=true}
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,t)
	return g:GetClassCount(Card.GetLinkCode)>2 and Duel.GetLocationCountFromEx(tp)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,c)
	local t={[id-3]=true,[id+8]=true,[id+5]=true}
	local g,mg,g1,mc=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,t),Group.CreateGroup()
	for i=0,2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g1=g:FilterSelect(tp,Card.IsLinkCode,1,1,nil,table.unpack(t))
		mg:Merge(g1)
		mc=g1:GetFirst()
		t[mc:GetLinkCode()]=nil
	end
	Duel.SendtoDeck(mg,nil,2,REASON_COST)
end
