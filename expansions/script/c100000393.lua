--[[
Voidictator Servant - Rune Thrall
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[If this card is Normal or Special Summoned: You can Set 1 "Voidictator" Spell/Trap from your hand, Deck, or GY to your field. It cannot be activated this turn, unless you control a face-up
	"Voidictator Deity" or "Voidictator Demon" monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is banished because of a "Voidictator" card you own, except "Voidictator Servant - Rune Thrall": You can target any number of face-up "Voidictator" Spell/Traps you control; return
	them to the hand, and if you do, you can banish up to 3 "Voidictator" cards from your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(s.spcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.setfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsST() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.Necro(s.setfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)>0 and aux.SetSuccessfullyFilter(tc) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetCondition(function(e) return tc:IsFacedown() and s.ctcon(e) end)
		tc:RegisterEffect(e1)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON)
end
function s.ctcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if not (rc and rc:IsOwner(tp)) then return false end
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid,code1,code2=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		if rc:IsRelateToChain(ch) then
			return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
		else
			return s.TriggeringSetcode[cid] and code1~=id and (not code2 or code2~=id)
		end
	else
		return rc:IsSetCard(ARCHE_VOIDICTATOR) and not rc:IsCode(id)
	end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsST() and c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	end
	local g=Duel.Select(HINTMSG_RTOHAND,true,tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and c:IsAbleToRemove()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 and Duel.BounceAndCheck(g) then
		local rg=Duel.Group(s.rmfilter,tp,LOCATION_HAND,0,nil)
		if #rg>0 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
			Duel.ShuffleHand(tp)
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rtg=rg:Select(tp,1,3,nil)
			Duel.Remove(rtg,POS_FACEUP,REASON_EFFECT)
		end
	end
end