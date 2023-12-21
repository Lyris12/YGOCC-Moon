--[[
Muscwole FLEXTREME Slam!
Muscolosso Slam FLEXTREMO!
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]


local s,id=GetID()
function s.initial_effect(c)
	--[[When your opponent activates a card or effect, while you control a "Muscwole" monster:
	Target 1 monster your opponent controls or in their GY (if possible); regardless, 1 "Muscwole" monster you control gains 700 ATK
	and cannot be targeted or banished by your opponent's card effects this turn, then, if it is your turn, until the end of the turn, that target's effects (if any) are negated,
	as well as the activated effects and effects on the field of monsters with the same original name.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can shuffle into the Deck, 3 of your other cards that are banished, in your hand and/or in your GY, including a "Muscwole" card;
	add this card to your hand, then, if you shuffled a card(s) from your hand into the Deck, draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabel(0)
	e2:SetFunctions(nil,s.thcost,s.thtg,s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MUSCWOLE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MUSCWOLE) and c:HasAttack()
end
function s.disfilter(c)
	return c:IsFaceupEx() and c:IsMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0
	end
	local tg=Duel.Select(HINTMSG_DISABLE,true,tp,s.disfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0,700)
	if #tg>0 then
		e:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,#tg,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATKDEF,false,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local c=e:GetHandler()
		local sc=g:GetFirst()
		local eff,diff=sc:UpdateATK(700,true,c)
		if diff>0 and not sc:IsImmuneToEffect(eff) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CANNOT_BE_TARGETED_BY_OPPONENT_EFFECT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetValue(aux.tgoval)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_REMOVE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(1,1)
			e2:SetTarget(s.rmlimit)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			sc:RegisterEffect(e2)
			local e2a=Effect.CreateEffect(c)
			e2a:SetDescription(aux.Stringid(id,1))
			e2a:SetType(EFFECT_TYPE_SINGLE)
			e2a:SetProperty(EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
			e2a:SetCode(id)
			e2a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			sc:RegisterEffect(e2a)
			
			local tc=Duel.GetFirstTarget()
			if Duel.GetTurnPlayer()==tp and tc and tc:IsRelateToChain() and tc:IsFaceupEx() and tc:IsMonster() and tc:IsControler(1-tp) then
				Duel.BreakEffect()
				local notfield=tc:IsInGY()
				Duel.Negate(tc,e,RESET_PHASE|PHASE_END,notfield)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetCode(EFFECT_DISABLE)
				e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
				e3:SetTarget(s.distg)
				e3:SetLabelObject(tc)
				e3:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e3,tp)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e4:SetCode(EVENT_CHAIN_SOLVING)
				e4:SetCondition(s.discon)
				e4:SetOperation(s.disop)
				e4:SetLabelObject(tc)
				e4:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e4,tp)
			end
		end
	end
end
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsHasEffect(id) and r&REASON_EFFECT~=0 and re:GetOwnerPlayer()~=tp
end
function s.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

--E2
function s.tdcfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_MUSCWOLE)
end
function s.gcheck(g)
	return g:IsExists(s.tdcfilter,1,nil)
end
function s.confirmfilter1(c)
	return c:IsSetCard(ARCHE_MUSCWOLE) and (not c:IsLocation(LOCATION_HAND) or c:IsPublic())
end
function s.confirmfilter2(c)
	return c:IsSetCard(ARCHE_MUSCWOLE) and c:IsLocation(LOCATION_HAND)
end
function s.checkfilter(c)
	return c:IsLocation(LOCATION_DECK|LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=LOCATION_GB
	if Duel.IsPlayerCanDraw(tp,1) then loc=loc|LOCATION_HAND end
	local g=Duel.Group(Card.IsAbleToDeckOrExtraAsCost,tp,loc,0,c)
	if chk==0 then
		return g:CheckSubGroup(s.gcheck,3,3)
	end
	e:SetLabel(0)
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	if #sg>0 then
		Duel.HintSelection(sg)
		if sg:FilterCount(s.confirmfilter1,nil)==0 then
			local cg=sg:Filter(s.confirmfilter2,nil)
			if #cg>1 then
				Duel.HintMessage(tp,HINTMSG_CONFIRM)
				cg=cg:Select(tp,1,1,nil)
			end
			Duel.ConfirmCards(1-tp,cg)
		end
		if Duel.ShuffleIntoDeck(sg,nil,nil,nil,REASON_COST)>0 then
			local ct=Duel.GetOperatedGroup():FilterCount(s.checkfilter,nil)
			e:SetLabel(ct)
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	if e:IsCostChecked() and e:GetLabel()>0 then
		Duel.SetTargetParam(1)
		e:SetCategory(CATEGORY_TOHAND|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetTargetParam(0)
		e:SetCategory(CATEGORY_TOHAND)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SearchAndCheck(c,tp) and Duel.GetTargetParam()>0 then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end