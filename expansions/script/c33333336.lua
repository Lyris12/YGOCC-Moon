--Sestosigillo Shikiogi
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	c:EnableReviveLimit()
	c:MustFirstBeSummoned(SUMMON_TYPE_DRIVE)
	--Drive Effects
	aux.AddDriveProc(c,12)
	local d1=c:DriveEffect(-15,0,CATEGORY_TODECK+CATEGORY_DAMAGE,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	local d2=c:OverDriveEffect(1,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.stattg,
		s.statop
	)
	--Monster Effects
	--destroy
	c:Ignition(2,CATEGORY_DESTROY,nil,LOCATION_MZONE,1,
		nil,
		aux.DiscardCost(),
		aux.DestroyTarget(nil,0,LOCATION_ONFIELD,1),
		s.desop
	)
	--add to hand
	c:SentToGYTrigger(false,4,CATEGORY_TOHAND,true,nil,
		aux.DueToHavingZeroEnergyCond,
		aux.DiscardCost(aux.Filter(Card.IsSetCard,0x7ea)),
		aux.SendToHandTarget(SUBJECT_THIS_CARD),
		aux.SendToHandOperation(SUBJECT_THIS_CARD)
	)
end
function s.tdfilter(c,tp)
	return Duel.IsPlayerCanSendtoDeck(tp,c)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_HAND,1,nil,1-tp) end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(1-tp,1)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	Duel.Damage(tp,1000,REASON_EFFECT,true)
	Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	Duel.RDComplete()
end

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x7ec)
end
function s.stattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,1000)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,LOCATION_MZONE,1000)
end
function s.statop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local rct = (Duel.IsEndPhase(1-tp)) and 2 or 1
		tc:UpdateATKDEF(1000,1000,{RESET_PHASE+PHASE_END+RESET_TURN_OPPO,rct},e:GetHandler())
	end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToChain() and c:IsFaceup() then
			c:SetMaximumNumberOfAttacksOnMonsters(2,RESET_PHASE+PHASE_END,nil,nil,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT,3)
		end
	end
end