--Galvanizer Gal
function c232001.initial_effect(c)
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
	e1:SetDescription(aux.Stringid(232001,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,232001)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c232001.spcon1)
	e1:SetCost(c232001.spcost)
	e1:SetTarget(c232001.sptg1)
	e1:SetOperation(c232001.spop1)
	c:RegisterEffect(e1)
end
function c232001.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function c232001.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c232001.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c232001.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SendtoGrave(c,REASON_RULE)
	end
	local g=Duel.GetDecktopGroup(tp,1)
	   local tc=g:GetFirst()
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsSetCard(0x232) then
			Duel.BreakEffect()
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
		end
end
end