--Varia-Mage Dual Recasters
function c249000522.initial_effect(c)
	--send s/t
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249000522.cost)
	e1:SetTarget(c249000522.tg)
	e1:SetOperation(c249000522.op)
	c:RegisterEffect(e1)
	--double attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function c249000522.costfilter(c)
	return c:IsSetCard(0x1C8) and c:IsAbleToRemoveAsCost()
end
function c249000522.costfilter2(c,e)
	return c:IsSetCard(0x1C8) and not c:IsPublic() and c~=e:GetHandler()
end
function c249000522.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000522.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000522.costfilter2,tp,LOCATION_HAND,0,1,nil,e)) end
	local option
	if Duel.IsExistingMatchingCard(c249000522.costfilter2,tp,LOCATION_HAND,0,1,nil,e)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000522.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000522.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000522.costfilter2,tp,LOCATION_HAND,0,1,nil,e) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000522.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000522.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000522.cfilter(c)
	return (c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD) and not c:IsHasEffect(EFFECT_REMAIN_FIELD))
	or (c:IsType(TYPE_TRAP) and not c:IsType(TYPE_CONTINUOUS) and not c:IsHasEffect(EFFECT_REMAIN_FIELD))
end
function c249000522.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.IsExistingMatchingCard(c249000522.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c249000522.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:FilterSelect(tp,c249000522.cfilter,1,1,nil)
	if sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT) then
		local tc=sg:GetFirst()
		local ae=tc:GetActivateEffect()
		if tc:GetLocation()==LOCATION_GRAVE and ae then
			if tc:IsType(TYPE_SPELL) then
				local e1=Effect.CreateEffect(tc)
				e1:SetDescription(ae:GetDescription())
				e1:SetType(EFFECT_TYPE_IGNITION)
				e1:SetCountLimit(1)
				e1:SetRange(LOCATION_GRAVE)
				e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
				e1:SetCondition(c249000522.spelltrapcon)
				if ae:GetCost() then e1:SetCost(ae:GetCost()) end
				if ae:GetTarget() then e1:SetTarget(ae:GetTarget()) end
				if ae:GetOperation() then e1:SetOperation(ae:GetOperation()) end
				tc:RegisterEffect(e1)
			else
				local e1=ae:Clone()
				e1:SetType(EFFECT_TYPE_QUICK_O)
				e1:SetCountLimit(1)
				e1:SetRange(LOCATION_GRAVE)
				e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
				e1:SetCondition(c249000522.spelltrapcon)
				tc:RegisterEffect(e1)
			end
			
		end
	end
	Duel.ShuffleDeck(tp)
end
function c249000522.spelltrapcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount() and e:GetHandler():CheckActivateEffect(false,false,false)~=nil
end