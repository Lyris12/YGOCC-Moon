--created by NovaTsukimori, coded by Lyris, art from Sailor Moon R Episode 9
--襲雷サンサーラ･ボルト
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x7c4) and c:IsDestructable()
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.filter(c,e,tp,lv)
	return not c:IsCode(lv) and c:IsSetCard(0x7c4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	local tc1=g1:GetFirst()
	if not tc1:IsRelateToEffect(e) or tc1:IsFacedown() or not tc1:IsSetCard(0x7c4) or tc1:IsControler(1-tp)
		or not tc:IsLocation(LOCATION_MZONE) or Duel.Destroy(tc1,REASON_EFFECT)==0 then return end
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc2=g2:GetFirst()
	if tc2:IsRelateToEffect(e) and not tc2:IsCode(tc1:GetCode()) and tc2:IsSetCard(0x7c4) then
		Duel.BreakEffect()
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end