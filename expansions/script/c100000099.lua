--Rescue Trappit
--Trappolaniglio da Soccorso
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[If exactly 1 monster is Normal or Flip Summoned, or Normal Set (except during the Damage Step):
	Set 2 "Trappit" cards from your Deck to your field, but banish them when they leave the field, also, until the end of the turn, you can activate 1 Trap the turn it was Set.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_MSET},s.egfilter,id)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
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
	--During your turn only, you can also activate this card from your hand.
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.acthandcon)
	c:RegisterEffect(e3)
end
function s.egfilter(c,_,_,eg,_,_,_,_,_,_,event)
	return #eg==1 and (c:IsSummonType(SUMMON_TYPE_NORMAL) or event==EVENT_FLIP_SUMMON_SUCCESS)
end

--Filters E1
function s.setfilter(c,e,tp)
	if not c:IsSetCard(ARCHE_TRAPPIT) or c:IsCode(id) then return false end
	return c:IsCanBeSet(e,tp,true,true)
end
function s.gcheck(g,c,G,f,min,max,ext_params)
	local mmz,stz=table.unpack(ext_params)
	return mmz>=g:FilterCount(Card.IsMonster,nil) and (stz>=g:FilterCount(s.notfield,nil) and g:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1)
end
function s.notfield(c)
	return c:IsST() and not c:IsType(TYPE_FIELD)
end
--Text sections E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local exc
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsLocation(LOCATION_HAND) then
			exc=c
		end
		if not Duel.IsExists(false,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,exc) then return false end
		local mmz,stz=Duel.GetMZoneCount(tp),Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsInBackrow() then
			stz=stz-1
		end
		local g=Duel.Group(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
		aux.GCheckAdditional=s.gcheck
		local res=g:CheckSubGroup(aux.TRUE,2,2,mmz,stz)
		aux.GCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		local mmz,stz=Duel.GetMZoneCount(tp),Duel.GetLocationCount(tp,LOCATION_SZONE)
		local g=Duel.Group(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
		aux.GCheckAdditional=s.gcheck
		local res=g:SelectSubGroup(tp,aux.TRUE,false,2,2,mmz,stz)
		aux.GCheckAdditional=nil
		if #res>0 and Duel.Set(tp,res)>0 then
			local og=res:Filter(Card.IsOnField,nil)
			for tc in aux.Next(og) do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_BANISH_REDIRECT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
				e1:SetValue(LOCATION_REMOVED)
				tc:RegisterEffect(e1,true)
			end
		end
		local e2=Effect.CreateEffect(c)
		e2:Desc(3)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetTargetRange(LOCATION_SZONE,0)
		e2:SetCountLimit(1,id)
		Duel.RegisterEffect(e2,tp)
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

function s.acthandcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,nil)
end