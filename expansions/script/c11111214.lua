--Rite of Rekindling
function c11111214.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,11111214)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11111214.sptg)
	e1:SetOperation(c11111214.spop)
	c:RegisterEffect(e1)
	--Did you ever reset yourself?
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,11111314)
	e3:SetCondition(c11111214.tdcon)
	e3:SetTarget(c11111214.settg)
	e3:SetOperation(c11111214.setop)
	c:RegisterEffect(e3)
end
--Peng
function c11111214.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:GetDefense()==200
end
function c11111214.rmfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk and c:IsAbleToGrave()
end
function c11111214.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11111214.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c11111214.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c11111214.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c11111214.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local g=Duel.GetMatchingGroup(c11111214.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttack())
			if #g>0 and Duel.SelectYesNo(tp,1191) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=g:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
	end
end
--Resettus Maximus
function c11111214.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK) and re:GetHandler():IsSetCard(0x5a1)
		and bit.band(r,REASON_EFFECT)~=0
end
function c11111214.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c11111214.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
