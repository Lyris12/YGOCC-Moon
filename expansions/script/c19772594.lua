--La Volontà degli AoJ
--Script by XGlitchy30
function c19772594.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772594,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19772594+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19772594.target)
	e1:SetOperation(c19772594.activate)
	c:RegisterEffect(e1)
	--back to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19772594,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c19772594.tdcon)
	e2:SetCost(c19772594.tdcost)
	e2:SetTarget(c19772594.tdtg)
	e2:SetOperation(c19772594.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
--filters
function c19772594.tdfilter(c,e,tp)
	return c:GetSummonPlayer()==tp and c:GetAttack()<=1500 and c:IsAbleToDeck()
		and (not e or (c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)))
end
--Activate
function c19772594.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function c19772594.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,0)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end
--back to deck
function c19772594.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c19772594.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function c19772594.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c19772594.tdfilter,1,nil,nil,1-tp)
		and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c19772594.tdop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0x197) then
			local g=eg:Filter(c19772594.tdfilter,nil,nil,1-tp)
			if g:GetCount()>0 then
				Duel.BreakEffect()
				local tc=nil
				if g:GetCount()>1 then
					tc=g:Select(tp,1,1,nil)
				else
					tc=g:GetFirst()
				end
				Duel.SetTargetCard(tc)
				Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
			end
		end
	end
end