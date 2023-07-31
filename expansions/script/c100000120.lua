--Wrath of the Time-Weaver
--Ira del Tessi-Tempo
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 monster on the field, then activate 1 of the following effects, depending whose turn it is.
	● Your turn: Banish that target until your opponent's next End Phase.
	● Your opponent's turn: Gain LP equal to the ATK or DEF of the targeted monster (whichever is higher, your choice if tied),
	then it cannot attack, its effects are negated, and it cannot be Tributed, or used as material for a Special Summon of a monster from the Extra Deck.
	These changes apply until your next End Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,aux.DiscardCost(),s.target,s.activate)
	c:RegisterEffect(e1)
end
--FE1
function s.filter1(c)
	local pos = c:GetPosition()&POS_FACEDOWN>0 and POS_FACEDOWN or POS_FACEUP
	return c:IsAbleToRemove(tp,pos)
end
function s.filter2(c)
	return c:IsFaceup() and (c:IsAttackAbove(1) or c:IsDefenseAbove(1))
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not chkc:IsLocation(LOCATION_MZONE) then return false end
		local lab=e:GetLabel()
		if lab==1 then
			return s.filter1(chkc)
		elseif lab==2 then
			return s.filter2(chkc)
		else
			return false
		end
	end
	local p=Duel.GetTurnPlayer()
	if chk==0 then
		local f = p==tp and s.filter1 or s.filter2
		return Duel.IsExists(true,f,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	if p==tp then
		e:SetCategory(CATEGORY_REMOVE)
		e:SetLabel(1)
		local g=Duel.Select(HINTMSG_REMOVE,true,tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	elseif p==1-tp then
		e:SetCategory(CATEGORY_RECOVER|CATEGORY_DISABLE)
		e:SetLabel(2)
		local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		local atk,def = tc:GetAttack(),tc:GetDefense()
		if not atk then atk=0 end
		if not def then def=0 end
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.max(atk,def))
		Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lab=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	if lab==1 then
		Duel.BanishUntil(tc,e,tp,nil,PHASE_END|RESET_OPPO_TURN,id,1,true,e:GetHandler(),REASON_EFFECT)
	elseif lab==2 then
		if not s.filter2(tc) then return end
		local atk,def = tc:GetAttack(),tc:GetDefense()
		if not atk then atk=0 end
		if not def then def=0 end
		if Duel.Recover(tp,math.max(atk,def),REASON_EFFECT)>0 and tc:IsRelateToChain() then
			Duel.BreakEffect()
			local c=e:GetHandler()
			local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_SELF_TURN
			local rct=Duel.GetNextPhaseCount(PHASE_END,tp)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(reset,rct)
			tc:RegisterEffect(e1)
			if tc:IsFaceup() then
				Duel.Negate(tc,e,{RESET_PHASE|PHASE_END|RESET_SELF_TURN,rct})
			end
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetReset(reset,rct)
			e2:SetValue(1)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetDescription(STRING_CANNOT_BE_TRIBUTED)
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e3)
			aux.CannotBeEDMaterial(tc,nil,nil,nil,{reset,rct},e:GetHandler())
			tc:RegisterFlagEffect(id,reset,EFFECT_FLAG_CLIENT_HINT,rct,0,STRING_CANNOT_BE_MATERIAL)
		end
	end
end