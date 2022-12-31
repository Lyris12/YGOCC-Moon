--created by Zolanark, coded by XGlitchy30
local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	local p1=Effect.CreateEffect(c)
	p1:SetDescription(aux.Stringid(id,0))
	p1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:SetCountLimit(1)
	p1:SetCost(s.thcost)
	p1:SetTarget(s.thtg)
	p1:SetOperation(s.thop)
	c:RegisterEffect(p1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.thcfilter(c)
	return c:IsSetCard(0x89f) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.thfilter(c)
	return c:IsSetCard(0x89f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.choicefilter(c,chk,attr,chk1,chk2,chk3,chk4)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x189f) and ((chk==0 and c:IsAttribute(attr))
		or ((c:IsAttribute(ATTRIBUTE_FIRE) and chk1) or (c:IsAttribute(ATTRIBUTE_WATER) and chk2) or (c:IsAttribute(ATTRIBUTE_EARTH) and chk3) or (c:IsAttribute(ATTRIBUTE_WIND) and chk4)))
end
function s.posfilter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
function s.checkshf(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1=Duel.CheckReleaseGroup(tp,s.choicefilter,1,e:GetHandler(),0,ATTRIBUTE_FIRE) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
	local chk2=Duel.CheckReleaseGroup(tp,s.choicefilter,1,e:GetHandler(),0,ATTRIBUTE_WATER) and Duel.GetMatchingGroupCount(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)>0
	local chk3=Duel.CheckReleaseGroup(tp,s.choicefilter,1,e:GetHandler(),0,ATTRIBUTE_EARTH) and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	local chk4=Duel.CheckReleaseGroup(tp,s.choicefilter,1,e:GetHandler(),0,ATTRIBUTE_WIND) and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)>0
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:GetHandler():IsReleasable() and (chk1 or chk2 or chk3 or chk4)
	end
	e:SetLabel(0)
	e:SetCategory(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroup(tp,s.choicefilter,1,1,e:GetHandler(),1,nil,chk1,chk2,chk3,chk4)
	local attr=g:GetFirst():GetAttribute()
	g:AddCard(e:GetHandler())
	Duel.Release(g,REASON_COST)
	if bit.band(attr,ATTRIBUTE_FIRE)>0 then
		e:SetLabel(e:GetLabel()+ATTRIBUTE_FIRE)
		e:SetCategory(e:GetCategory()+CATEGORY_DAMAGE)
		local dg=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dg*500)
	end
	if bit.band(attr,ATTRIBUTE_WATER)>0 then
		e:SetLabel(e:GetLabel()+ATTRIBUTE_WATER)
		e:SetCategory(e:GetCategory()+CATEGORY_TODECK)
		local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
	end
	if bit.band(attr,ATTRIBUTE_EARTH)>0 then
		e:SetLabel(e:GetLabel()+ATTRIBUTE_EARTH)
		e:SetCategory(e:GetCategory()+CATEGORY_POSITION+CATEGORY_DEFCHANGE)
		local dg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,dg,#dg,0,0)
	end
	if bit.band(attr,ATTRIBUTE_WIND)>0 then
		e:SetLabel(e:GetLabel()+ATTRIBUTE_WIND)
		e:SetCategory(e:GetCategory()+CATEGORY_RECOVER)
		local dg=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dg*300)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if bit.band(opt,ATTRIBUTE_FIRE)>0 then
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
	if bit.band(opt,ATTRIBUTE_WATER)>0 then
		local ct=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
		if #ct>0 then
			Duel.SendtoDeck(ct,nil,2,REASON_EFFECT)
			for p=0,1 do
				if ct:IsExists(s.checkshf,1,nil,p) then
					Duel.ShuffleDeck(p)
				end
			end
		end
	end
	if bit.band(opt,ATTRIBUTE_EARTH)>0 then
		local ct=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #ct>0 then
			Duel.ChangePosition(ct,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			local tc=g:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_DEFENSE)
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
		end
	end
	if bit.band(opt,ATTRIBUTE_WIND)>0 then
		local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end