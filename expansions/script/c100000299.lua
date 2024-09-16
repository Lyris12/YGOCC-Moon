--[[
Dynastygian Sabotage - Engine Misfire
Sabotaggio Dinastigiano - Avaria del Motore
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of the following effects, depending on who the owner of this card is.
	● You: Target 1 face-up monster your opponent controls and roll a six-sided die; negate the effects of that target until the Nth turn after this effect resolves (N = the result).
	If you control a face-up DARK "Number" Xyz Monster that has 2 or more materials, your opponent cannot activate cards or effects in response to this effect's activation.
	● Your opponent: Return, to the hand, the monster you control with the highest ATK or DEF (whichever is higher) among monsters you control (your opponent's choice, if tied),
	and if you do, you cannot Special Summon monsters with the same name that monster had on the field until the 3rd Standby Phase after this effect resolves.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this Set card in your opponent's Spell & Trap Zone is sent to the GY: You can declare 1 card name; your opponent must banish as many cards from their hand, Deck, field, GY,
	and Extra Deck as possible with that same original name, face-down. During your 2nd Standby Phase after this effect resolves, shuffle as many banished cards into the Decks as possible.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
	c:RegisterEffect(e2)
end
s.toss_dice=true

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()>=2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local p=c:GetOwner()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if chk==0 then
		if p==tp then
			return Duel.IsExists(true,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
		elseif p==1-tp then
			local g=Duel.Group(aux.Faceup(Card.IsAbleToHand),tp,LOCATION_MZONE,0,nil)
			return #g>0
		else
			return false
		end
	end
	if p==tp then
		Duel.SetTargetParam(1)
		e:SetCategory(CATEGORY_DISABLE|CATEGORY_DICE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_DISABLE,true,tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
		if Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			Duel.SetChainLimit(aux.ChainLimitOppo)
		end
	elseif p==1-tp then
		Duel.SetTargetParam(2)
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		local g=Duel.Group(aux.Faceup(Card.IsAbleToHand),tp,LOCATION_MZONE,0,nil)
		local maxg=g:GetMaxGroup(Card.GetMaxStat)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,maxg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local param=Duel.GetTargetParam()
	local tp=not Duel.PlayerHasFlagEffect(0,CARD_NUMBER_IC212) and tp or Duel.GetFlagEffectLabel(0,CARD_NUMBER_IC212)
	if param==1 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			local rct=Duel.TossDice(tp,1)
			local e1,e2,res=Duel.Negate(tc,e,{RESET_PHASE|PHASE_END,rct},false,false,TYPE_MONSTER)
			if res then
				aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,rct,nil,nil,e1,e2)
			end
		end
	elseif param==2 then
		local g=Duel.Group(aux.Faceup(Card.IsAbleToHand),tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		local maxg=g:GetMaxGroup(Card.GetMaxStat)
		local tc
		if #maxg>1 then
			Duel.HintMessage(1-tp,HINTMSG_RTOHAND)
			local tg=maxg:Select(1-tp,1,1,nil)
			Duel.HintSelection(tg)
			tc=tg:GetFirst()
		else
			tc=maxg:GetFirst()
		end
		local codes={tc:GetCode()}
		if Duel.BounceAndCheck(tc) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,1)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.sumlimit)
			e1:SetLabel(table.unpack(codes))
			e1:SetReset(RESET_PHASE|PHASE_STANDBY,3)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end

--E2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5 and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.privatefilter(c)
	return c:IsFacedown() or not c:IsPublic()
end
function s.publicfilter(c,code,topdeck)
	return (c:IsFaceup() or c:IsPublic()) and (not c:IsLocation(LOCATION_DECK) or c~=topdeck) and c:IsOriginalCodeRule(code)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local locs=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK|LOCATION_EXTRA
	local g=Duel.GetFieldGroup(tp,0,locs)
	if chk==0 then return Duel.IsPlayerCanRemove(1-tp) and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) end
	local code
	if Duel.GetDeckCount(1-tp)>1 or g:IsExists(s.privatefilter,1,nil) then
		code=Duel.AnnounceCard(tp)
	else
		s.announce_filter={}
		local check=false
		for tc in aux.Next(g) do
			local names={tc:GetOriginalCodeRule()}
			for _,name in ipairs(names) do
				table.insert(s.announce_filter,name)
				table.insert(s.announce_filter,OPCODE_ISCODE)
				if check then
					table.insert(s.announce_filter,OPCODE_OR)
				else
					check=true
				end
			end
		end
		code=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	end
	Duel.SetTargetParam(code)
	local cg=g:Filter(s.publicfilter,nil,code,Duel.GetDecktopGroup(1-tp,1):GetFirst())
	if #cg>0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,cg,#cg,1-tp,0,locs)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,0,locs)
	end
end
function s.rmfilter(c,p,code)
	return c:IsOriginalCodeRule(code) and c:IsAbleToRemove(p,POS_FACEDOWN,REASON_RULE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanRemove(1-tp) then
		local code=Duel.GetTargetParam()
		local locs=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK|LOCATION_EXTRA
		local g=Duel.GetFieldGroup(tp,0,locs):Filter(s.rmfilter,nil,1-tp,code)
		if #g>0 then
			Duel.Remove(g,POS_FACEDOWN,REASON_RULE,1-tp)
		end
	end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,3)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:OPT()
	e1:SetLabel(0)
	e1:SetCondition(aux.TurnPlayerCond(0))
	e1:SetOperation(s.tdop)
	e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e1,tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	c:SetTurnCounter(ct)
	if ct==2 then
		local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	if ct>=2 then e:Reset() end
end