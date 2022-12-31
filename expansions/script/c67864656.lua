--VECTOR Engineering Readiness
--Scripted by Keddy, fixed by Zerry
function c67864656.initial_effect(c)
	--Activate/draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(c67864656.drop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67864656,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,67864656)
	e2:SetCondition(c67864656.spcon)
	e2:SetTarget(c67864656.sptg)
	e2:SetOperation(c67864656.spop)
	c:RegisterEffect(e2)
end
function c67864656.drop(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(67864656,0)) then
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function c67864656.spgfilter(c,e,tp)
	local lv=c:GetLevel()
	return lv>1 and c:IsSetCard(0x62a6) and c:IsControler(tp) and c:IsFaceup()
		and Duel.IsExistingTarget(c67864656.spgfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv)
end
function c67864656.spgfilter2(c,e,tp,lv)
	return c:GetLevel()>0 and c:IsLevelBelow(lv-1) and c:IsSetCard(0x2a6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c67864656.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c67864656.spgfilter,1,nil,e,tp)
end
function c67864656.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c67864656.spgfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c67864656.spgfilter,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c67864656.spgfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg:GetFirst():GetLevel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c67864656.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
