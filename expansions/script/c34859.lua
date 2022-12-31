--Progressione tramite Automazione
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,1)
	local d1=c:DriveEffect(3,0,CATEGORY_DRAW,EFFECT_TYPE_IGNITION,EFFECT_FLAG_PLAYER_TARGET,nil,
		nil,
		aux.ToHandCost(s.cfilter,LOCATION_MZONE,0,1),
		aux.DrawTarget(),
		aux.DrawOperation()
	)
	local d2=c:DriveEffect(-11,1,CATEGORY_REMOVE+CATEGORY_DRAW,EFFECT_TYPE_QUICK_O,nil,nil,
		s.rmcon,
		nil,
		s.rmtg,
		s.rmop
	)
	--Monster Effects
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--search 2
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond(0))
	e2:SetCost(aux.LabelCost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<3
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemove(tp,POS_FACEDOWN)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if ct<5 and Duel.IsPlayerCanDraw(tp,5-ct) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Draw(tp,5-ct,REASON_EFFECT)
		end
	end
end

function s.filter(c)
	return c:IsSetCard(0x660) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end

function s.dfilter(c,tp)
	return c:IsSetCard(0x660) and c:IsDiscardable() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c)
end
function s.thfilter(c,cc)
	return c:IsMonster() and c:IsAbleToHand() and aux.IsCodeListed(cc,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)>0 then
			e:SetLabelObject(tc)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local sc=g:GetFirst()
		if sc:IsMonster(TYPE_DRIVE) and sc:IsCanEngage(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.BreakEffect()
			sc:Engage(e,tp)
		end
	end
end