--Aircaster Ignition
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AIRCASTER) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqfilter1(c,tp)
	return c:IsSetCard(ARCHE_AIRCASTER) and c:IsLevel(3) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not (chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)) then return false end
		local opt=e:GetLabel()
		if opt==0 then
			return s.eqfilter1(chkc,tp)
		elseif opt==1 then
			return s.spfilter(chkc,e,tp)
		end
		return false
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsInBackrow() then
		ft=ft-1
	end
	local b1 = (ft>0 and Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_GRAVE,0,1,nil,tp))
	local b2 = (Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp))
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	if not opt then return end
	if opt==0 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.eqfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		Duel.SetCardOperationInfo(g,CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
	elseif opt==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	end
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local opt=e:GetLabel()
	if opt==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local eqg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc)
		if #eqg>0 then
		Duel.HintSelection(eqg)
		local ec=eqg:GetFirst()
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,ec)
		end
		
	elseif opt==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
