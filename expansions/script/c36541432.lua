--Runic Engraving Effect
--Script by XGlitchy30
function c36541432.initial_effect(c)
	--reveal
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36541431,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c36541432.revcon)
	e1:SetCost(c36541432.revcost)
	e1:SetOperation(c36541432.revop)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36541431,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c36541432.drcost)
	e2:SetTarget(c36541432.drtg)
	e2:SetOperation(c36541432.draw)
	c:RegisterEffect(e2)
	--negate attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36541431,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c36541432.atkcon)
	e3:SetCost(c36541432.atkcost)
	e3:SetOperation(c36541432.atkop)
	c:RegisterEffect(e3)
end
--filters
function c36541432.discard(c)
	return c:IsAbleToGrave() and c:IsDiscardable()
end
--reveal
function c36541432.revcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPublic()
end
function c36541432.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(36541432,RESET_EVENT+0x1fe0000+RESET_CHAIN,0,0)
end
function c36541432.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPublic() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		c:RegisterEffect(e1)
	end
end
--draw
function c36541432.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c36541432.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) 
		and Duel.IsExistingMatchingCard(c36541432.discard,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c36541432.draw(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c36541432.discard,tp,LOCATION_HAND,0,1,nil) then return end
	local c=e:GetHandler()
	local top=Duel.GetDecktopGroup(tp,1)
	local tc=top:GetFirst()
	Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc and tc:IsAttribute(c:GetAttribute()) and Duel.IsPlayerCanDraw(tp,1) then
		if Duel.SelectYesNo(tp,aux.Stringid(36541431,3)) then
			Duel.ConfirmCards(1-tp,tc)
			c:RegisterFlagEffect(36540432,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
			Duel.Draw(tp,1,REASON_EFFECT)
			Duel.ShuffleHand(tp)
		else return end
	end
end
--negate attack		
function c36541432.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=Duel.GetAttacker()
	return at:GetControler()~=tp and at:IsAttribute(c:GetAttribute()) and Duel.GetAttackTarget()==nil
end
function c36541432.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c36541432.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end