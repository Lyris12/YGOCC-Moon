--created & coded by Lyris, art from Yu-Gi-Oh! Duel Monsters Episode 158
--インライトメント・アルティマ エアトス
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id-10)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetDescription(1122)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x1da6),LOCATION_MZONE)
end
function s.spfilter(c,tp)
	return c:IsCode(id-10) and Duel.GetMZoneCount(tp,c)>0
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xda6) and c:IsAbleToDeckAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.spfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	local g=Duel.SelectReleaseGroup(tp,s.spfilter,1,1,nil,tp)
	Duel.SendtoDeck(dg,nil,2,REASON_COST)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,Card.IsAttackAbove,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,1):GetFirst()
	if tc then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack()//2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.Damage(1-tp,tc:GetAttack()//2,REASON_EFFECT) end
end
