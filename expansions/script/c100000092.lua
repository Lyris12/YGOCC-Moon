--Trappit Trap Hole
--Buco Trappolaniglio
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id=GetID()
function s.initial_effect(c)
	--[[If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step): Add 1 "Trappit" monster from your Deck to your hand, also you can apply 1 of these effects.
	● Immediately after this effect resolves, Normal Summon/Set 1 monster.
	● Flip Summon 1 monster.
	● Send from your Deck to the GY, 1 Normal Trap that activates when a monster(s) is Normal or Flip Summoned, or Normal Set, except "Trappit Trap Hole", and that meets its activation conditions, and if you do, apply its effect when that card is activated.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_SUMMON|CATEGORY_POSITION|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card, then target 1 "Trappit" monster you control, even if Set;
	return it to the hand, and if you do, immediately after this effect resolves, Normal Summon/Set 1 monster (if you can).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(6)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(aux.TurnPlayerCond(0))
	c:RegisterEffect(e3)
end

--Filters E1
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToHand()
end
function s.actfilter(c)
	if not c:IsNormalTrap() or not c:IsAbleToGrave() or c:IsCode(id) or c:CheckActivateEffect(false,true,true)==nil then return false end
	local egroup=c:GetEffects()
	local res=false
	for i,e in ipairs(egroup) do
		if e and not e:WasReset(c) then
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
				local event=e:GetCode()
				if (event==EVENT_SUMMON_SUCCESS or event==EVENT_FLIP_SUMMON_SUCCESS) or e:IsHasCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET) then
					res=true
					break
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
	
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local shuffle=false
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 then
			shuffle=true
		end
	end
	if not e:GetHandler():AskPlayer(tp,2) then return end
	if shuffle then
		Duel.ShuffleHand(tp)
	end
	local b1=Duel.IsExistingMatchingCard(Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,nil,tp,true)
	local b3=Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil)
	local opt=aux.Option(tp,id,3,b1,b2,b3)
	if opt==0 then
		local g=Duel.Select(HINTMSG_SUMMON,false,tp,Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.SummonOrSet(tp,tc)
		end
		
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_POSITION,false,tp,Card.IsCanBeFlipSummoned,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
		local tc=g:GetFirst()
		if tc then
			Duel.FlipSummon(tp,tc)
		end
		
	elseif opt==2 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
			if not te then return end
			local tg=te:GetTarget()
			local op=te:GetOperation()
			Duel.SetProxyEffect(e,te)
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			Duel.ResetProxyEffect()
			Duel.BreakEffect()
			tc:CreateEffectRelation(te)
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				for etc in aux.Next(g) do
					etc:CreateEffectRelation(te)
				end
			end
			Duel.SetProxyEffect(e,te)
			if op then op(e,tp,ceg,cep,cev,cre,cr,crp) end
			Duel.ResetProxyEffect()
			tc:ReleaseEffectRelation(te)
			if g then
				for etc in aux.Next(g) do
					etc:ReleaseEffectRelation(te)
				end
			end
		end
	end
end

--Filters E2
function s.bfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToHand()
end
--Text sections E2
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.bfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.bfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_RTOHAND,true,tp,s.bfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetFirst():IsFacedown() then
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	if Duel.IsPlayerCanSummon(tp) then
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT) and tc:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(tp)
		local g=Duel.Select(HINTMSG_SUMMON,false,tp,Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			Duel.SummonOrSet(tp,g:GetFirst())
		end
	end
end