--MMS - Jacklyn Alltrades
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,nil,true,true,
		nil,
		nil,
		s.target,
		s.operation
	)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionType(TYPE_MONSTER) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
		and (not mg or #mg<2 or mg:IsExists(Card.IsFusionSetCard,1,nil,0xd71))
end

function s.thfilter(c)
	return c:IsCode(19905910) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsOnField() and chkc~=c
		elseif e:GetLabel()==2 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove()
		else
			return false
		end
	end
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	local b3=Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	e:SetLabel(0)
	e:SetCategory(0)
	e:SetProperty(EFFECT_FLAG_DDD)
	local opt=aux.Option(id,tp,1,b1,b2,b3)
	if opt==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif opt==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DDD+EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_DESTROY,true,tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation())
	elseif opt==2 then
		e:SetCategory(CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_DDD+EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_REMOVE,true,tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation())
	end
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		aux.SearchOperation(aux.Filter(Card.IsCode,19905910),LOCATION_DECK+LOCATION_GRAVE)(e,tp,eg,ep,ev,re,r,rp)
	elseif opt==1 then
		aux.DestroyOperation(SUBJECT_IT)(e,tp,eg,ep,ev,re,r,rp)
	elseif opt==2 then
		aux.BanishOperation(SUBJECT_IT)(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsOnField() and bc:IsControler(1-tp) and bc:IsCanBeEffectTarget(e) and c:IsAbleToRemove() and bc:IsAbleToRemove() end
	Duel.SetTargetCard(bc)
	local g=Group.FromCards(c,bc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,PLAYER_ALL,LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or not tc:IsRelateToChain() then return end
	local g=Group.FromCards(c,tc)
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local oc=og:GetFirst()
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(Card.HasFlagEffect,nil,id)
	g:DeleteGroup()
	for tc in aux.Next(sg) do
		Duel.ReturnToField(tc)
	end
end