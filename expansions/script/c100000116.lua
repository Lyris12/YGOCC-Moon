--Miss Mecha & Intelligent Spirit
--Miss Mecha & Spirito Intelligente
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[① When a card(s) you control is destroyed by your opponent, even during the Damage Step (Quick Effect): You can send this card from your hand or field to the GY;
	during the End Phase of this turn, your opponent can have you draw a number of cards equal to the number of cards that were destroyed this turn to negate this effect,
	otherwise your opponent draws that number of cards, and if they do, they must send a number of cards from the top of their Deck to the GY, equal to the number of cards in their hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_DISABLE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetFunctions(s.condition,aux.ToGraveSelfCost,nil,s.operation)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for i=1,#eg do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end

--FE1
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.cfilter,1,nil,tp) and (not eg:IsContains(c) or not c:IsOnField())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(1)
	e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
	e1:SetCheatCode(CHEATCODE_SET_CHAIN_ID,false,cid)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drawcon)
	e1:SetOperation(s.drawop)
	e1:SetReset(RESET_PHASE|PHASE_END,1)
	Duel.RegisterEffect(e1,tp)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(0,id)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(0,id)
	if not ct or ct<=0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.IsChainDisablable(0) then
		if Duel.IsPlayerCanDraw(tp,ct) and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
			Duel.Draw(tp,ct,REASON_EFFECT)
			Duel.NegateEffect(0)
			return
		end
	end
	local dct=Duel.Draw(1-tp,ct,REASON_EFFECT)
	if dct>0 then
		local hct=Duel.GetHandCount(1-tp)
		if Duel.GetDeckCount(1-tp)>0 and hct>0 then
			Duel.ShuffleHand(1-tp)
			Duel.DisableShuffleCheck()
			local dg=Duel.GetDecktopGroup(1-tp,hct)
			Duel.SendtoGrave(dg,REASON_RULE,1-tp)
		end
	end
end