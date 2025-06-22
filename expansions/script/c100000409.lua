--[[
Unknown HERO Foresight
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	aux.AddMaterialCodeList(c,100000406)
	c:EnableReviveLimit()
	--"Unknown HERO Masquerade" + 1+ non-Tuner monsters
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,100000406),aux.NonTuner(nil),1)
	--Must first be Synchro Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	--If this card is Synchro Summoned, or when your opponent activates the effect of a card from their hand while you control this monster (in which case this is a Quick Effect): You can target 2 "HERO" cards in your GY (including at least 1 "Unknown HERO" card); shuffle those targets into the Deck, and if you do, negate the activation of the next card or effect your opponent activates and banish that card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_NEGATE|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetType(EFFECT_TYPE_QUICK_O)
	e2x:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2x:SetCode(EVENT_CHAINING)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetFunctions(
		s.negcon,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2x)
	--Your opponent must play with their hand revealed, also both player's hand size limit becomes 7.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_HAND_LIMIT)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(7)
	c:RegisterEffect(e4)
	--If this card battles an opponent's monster, it gains 400 ATK/DEF for each card in both player's hands during damage calculation only.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	e5:UpdateDefenseClone(c)
end
s.material_type=TYPE_RITUAL

--E1
function s.tdfilter(c,e)
	return c:IsSetCard(ARCHE_HERO) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdfirst(c)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then
		if not xgl.SelectUnselectGroup(0,g,e,tp,2,2,aux.TRUE,0,nil,nil,nil,nil,nil,s.tdfirst) then return false end
		if e:GetCode()==EVENT_CHAINING then
			return aux.nbtg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,2,2,aux.TRUE,1,tp,HINTMSG_TODECK,nil,nil,nil,s.tdfirst)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	aux.nbtg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsSetCard,nil,ARCHE_HERO)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local code=e:GetCode()
		if code==EVENT_CHAINING then
			if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
				Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
			end
		else
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetDescription(id,1)
			e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_CHAINING)
			e3:OPT()
			e3:SetCondition(s.negconreg)
			e3:SetOperation(s.negopreg)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.negconreg(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActivated()
end
function s.negopreg(e,tp,eg,ep,ev,re,r,rp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_ACTIVATING)
	e3:OPT()
	e3:SetCondition(function(E,TP,EG,EP,EV,RE,R,RP) return RE==re end)
	e3:SetOperation(s.negopreg2)
	e3:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e3,tp)
	e:Reset()
end
function s.negopreg2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateActivation(ev) and rc:IsRelateToChain(ev) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
	e:Reset()
end
--E2X
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and Duel.IsChainNegatable(ev)) then return false end
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return p==1-tp and loc&LOCATION_HAND>0
end

--E5
function s.atkcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	local d=c:GetBattleTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and d and d:IsControler(1-tp)
end
function s.atkval(e,c)
	local ct=Duel.GetHandCount()
	return math.max(0,ct*400)
end