--Galvanizer King Vector
function c232004.initial_effect(c)
	local NoF=Effect.CreateEffect(c)
	NoF:SetType(EFFECT_TYPE_SINGLE)
	NoF:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	NoF:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	NoF:SetValue(function(e,c) if not c then return false end return not c:IsAttribute(ATTRIBUTE_LIGHT) end)
	c:RegisterEffect(NoF)
	local NoS=NoF:Clone()
	NoS:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(NoS)
	local NoX=NoF:Clone()
	NoX:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(NoX)
	local NoL=NoF:Clone()
	NoL:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(NoL)
--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(232004,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,232004)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c232004.spcon1)
	e1:SetCost(c232004.spcost)
	e1:SetTarget(c232004.sptg1)
	e1:SetOperation(c232004.spop1)
	c:RegisterEffect(e1)
end
function c232004.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function c232004.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c232004.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c232004.thfilter(c)
	return c:IsSetCard(0x232) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function c232004.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c232004.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.MoveSequence(sg:GetFirst(),0)
			Duel.ConfirmCards(1-tp,sg)
			local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
			local di=g:RandomSelect(1-tp,1)
			Duel.SendtoGrave(di,REASON_EFFECT)
		end
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
end