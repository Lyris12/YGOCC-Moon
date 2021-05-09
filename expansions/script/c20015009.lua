--Pastel Palettes - Dream Gradient
--Script by XyLeN
function c20015009.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20015009+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c20015009.target)
	e1:SetOperation(c20015009.activate)
	c:RegisterEffect(e1)
end
local band_hina=20015002
local band_aya=20015004
local band_maya=20015008
local band_loc=LOCATION_DECK+LOCATION_HAND
function c20015009.hinafilter(c,e,tp) 
	return c:IsCode(band_hina) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20015009.ayafilter(c,e,tp) 
	return c:IsCode(band_aya) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20015009.mayafilter(c,e,tp) 
	return c:IsCode(band_maya) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20015009.filter(c)
	return not aux.LvL6or7Check(c) and c:IsSetCard(0x880) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c20015009.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20015009.filter(chkc) end
	if chk==0 then
		local hina=Duel.IsExistingMatchingCard(c20015009.hinafilter,tp,band_loc,0,1,nil,e,tp) 
		local aya=Duel.IsExistingMatchingCard(c20015009.ayafilter,tp,band_loc,0,1,nil,e,tp) 
		local maya=Duel.IsExistingMatchingCard(c20015009.mayafilter,tp,band_loc,0,1,nil,e,tp) 
		local check=Duel.IsExistingTarget(c20015009.filter,tp,LOCATION_GRAVE,0,1,nil)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return ft>0 and check and (hina or aya or maya)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c20015009.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c20015009.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		local filter
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsCode,1,nil,20015001) then
			filter=c20015009.hinafilter
		elseif og:IsExists(Card.IsCode,1,nil,20015003) then
			filter=c20015009.ayafilter
		elseif og:IsExists(Card.IsCode,1,nil,20015007) then
			filter=c20015009.mayafilter
		end
		c20015009.specialsummon(e,tp,filter)
	end
end
function c20015009.specialsummon(e,tp,filter)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,filter,tp,band_loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end