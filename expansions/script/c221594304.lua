--created by Walrus, coded by XGlitchy30
--Voidictator Servant - Rune Artist
local s,id=GetID()
function s.initial_effect(c)
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.BanishCost(s.cfilter,LOCATION_GRAVE))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	e:SetLabel(0)
	local loc=c:GetLocation()
	if Duel.SendtoGrave(c,REASON_COST)>0 then
		if c:IsLocation(LOCATION_GRAVE) and loc&LOCATION_ONFIELD>0 then
			e:SetLabel(1)
		end
	end
end
function s.filter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR_RUNE) and c:IsST() and c:IsAbleToHand()
end
function s.rmfilter(c)
	return c:IsSpellTrapOnField() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then e:SetLabel(0) end
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	local lab=e:GetLabel()
	Duel.SetTargetParam(lab)
	if lab==1 then
		e:SetCategory(CATEGORIES_SEARCH|CATEGORY_REMOVE)
		local g=Duel.Group(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_ONFIELD)
	else
		e:SetCategory(CATEGORIES_SEARCH)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) and Duel.GetTargetParam()==1 and e:IsActivated() then
		local g=Duel.Group(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg=g:Select(tp,1,1,nil)
			if #rg>0 then
				Duel.HintSelection(rg)
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.cfilter(c)
	return c:IsST() and c:IsSetCard(ARCHE_VOIDICTATOR_RUNE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end
