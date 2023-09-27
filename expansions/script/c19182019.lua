--Aircaster Predicament
--created by Alastar Rainford, coded by Lyris

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsInBackrow,tp,LOCATION_SZONE,0,nil)
	if chk==0 then
		if #g==0 then return false end
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() then
			g:AddCard(c)
		end
		return not g:IsExists(aux.NOT(Card.IsAbleToGraveAsCost),1,nil)
	end
	g=g:Filter(Card.IsAbleToGraveAsCost,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.plfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(ARCHE_AIRCASTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() then
			ft=ft-1
		end
		return ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local sg=Duel.Group(aux.Necro(s.plfilter),tp,LOCATION_GRAVE,0,nil,tp)
	for i=1,math.min(#sg,ft) do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=sg:Select(tp,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			sg:RemoveCard(tc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local eqg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if #eqg>0 then
				Duel.HintSelection(eqg)
				local ec=eqg:GetFirst()
				Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,ec,true,true)
			end
		end
	end
	Duel.EquipComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AIRCASTER) and c:GetSequence()<5
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,0,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end