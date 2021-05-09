--Pastel Palettes - Maya
--Script by XyLeN
function c20015007.initial_effect(c)
	--sp summon
	c:RegisterEffect(aux.AddPastelPalettesSpSummonEffect(c,20015007,aux.Stringid(20015007,0)))
	--sp summon grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20015007,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCountLimit(1,20015007+200)
	e1:SetTarget(c20015007.target)
	e1:SetOperation(c20015007.operation)
	c:RegisterEffect(e1)
end
function c20015007.filter(c,e,tp)
	return not aux.LvL6or7Check(c) and c:IsSetCard(0x880) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20015007.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20015007.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c20015007.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c20015007.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c20015007.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

dofile("script/Pastel Palettes Core.lua")