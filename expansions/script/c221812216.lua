--[[
Cryptolocker
Criptoforziere
Card Author: Burndown
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When a monster effect is activated on the field: Activate this card by banishing 1 Cyberse monster you control; negate that effect, and if you do, banish that monster.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabel(0)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this face-up card leaves the field: Special Summon the monster banished by this card's previous effect to its owner's field,
	then you can shuffle 1 of your banished Cyberse monsters into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    return loc&LOCATION_ONFIELD>0 and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then return not rc:IsDisabled() and (rc:IsAbleToRemove() or (not relation and Duel.IsPlayerCanRemove(tp))) end
	local c=e:GetHandler()
	e:SetLabel(0)
	c:ResetFlagEffect(id+1)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToChain() then
		local tc=eg:GetFirst()
		if tc:IsBanished() and tc:IsMonster() and tc:IsReason(REASON_EFFECT) and tc:GetReasonEffect()==e then
			local eid=e:GetFieldID()
			c:RegisterFlagEffect(id+1,0,0,1,eid)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,1))
			e:SetLabel(eid)
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local se=e:GetLabelObject()
	local eid=se:GetLabel()
	se:SetLabel(0)
	local tc=Duel.GetFirstMatchingCard(Card.HasFlagEffectLabel,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,id,eid)
	if c:HasFlagEffectLabel(id+1,eid) then
		if tc then
			Duel.SetTargetCard(tc)
			tc:ResetFlagEffect(id)
			Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
			Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
		else
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,LOCATION_REMOVED)
		end
	else
		if tc then
			tc:ResetFlagEffect(id)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,LOCATION_REMOVED)
	end
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_CYBERSE) and c:IsAbleToDeck()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsMonster() then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_MZONE,tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,p) and Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)>0 then
			local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
			if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_TO_DECK) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local tg=g:Select(tp,1,1,nil)
				if #tg>0 then
					Duel.HintSelection(tg)
					Duel.BreakEffect()
					Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end