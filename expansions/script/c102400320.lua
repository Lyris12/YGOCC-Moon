--created by Ace/Verloren of Discord
--Dominus Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_PENDULUM))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetOperation(s.act)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC)
	e4:SetRange(LOCATION_HAND)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(s.scon)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.splimit)
	c:RegisterEffect(e5)
end
function s.filter(c,e,tp,lv)
	return c:IsLevelBelow(lv-1) and c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.act(e,tp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,7)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(g:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end
function s.con(e,tp,eg,ep)
	if ep==tp and eg:IsExists(s.cfilter,1,nil) then
		local _,lv=eg:GetMaxGroup(Card.GetLevel)
		e:SetLabel(lv)
		return true
	end
	return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain()
	if not (#g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv),0,tp,tp,false,false,POS_FACEUP)
end
function s.sfilter(c,at)
	return c:IsFaceup() and c:IsAttribute(at) and c:IsRace(RACE_DRAGON)
end
function s.scon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_DARK)
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_LIGHT)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return sumtp&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
