--Multitask Clonadati
--Script by XGlitchy30
function c86433607.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86433607,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,86433607)
	e1:SetCost(c86433607.sccost)
	e1:SetTarget(c86433607.sctg)
	e1:SetOperation(c86433607.scop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	--target 2 cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86433607,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c86433607.target)
	e2:SetOperation(c86433607.operation)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(86433607,ACTIVITY_SPSUMMON,c86433607.counterfilter)
end
--filters
function c86433607.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or (c:IsType(TYPE_LINK) and c:IsRace(RACE_CYBERSE))
end
function c86433607.scfilter(c)
	return c:IsSetCard(0x86f) and c:IsAbleToHand()
end
function c86433607.checksum(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function c86433607.filter(c,tp)
	return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) 
		and (c:IsAbleToHand() and Duel.IsExistingMatchingCard(c86433607.hand,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c) 
		or c:IsAbleToRemove() and Duel.IsExistingMatchingCard(c86433607.remove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,c))
end
function c86433607.dfilter(c)
	return not c:IsRace(RACE_CYBERSE) or c:IsFacedown()
end
function c86433607.hand(c)
	return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) 
		and c:IsAbleToHand() 
end
function c86433607.remove(c)
	return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) 
		and c:IsAbleToRemove()
end
--search
function c86433607.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(86433607,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86433607.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c86433607.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_CYBERSE) and not c:IsType(TYPE_LINK)
end
function c86433607.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local req=true
	local check=Duel.GetMatchingGroupCount(c86433607.checksum,tp,0,LOCATION_MZONE,nil)
	if check>1 then
		req=Duel.IsPlayerCanDraw(tp,math.floor(check/2))
	end
	if chk==0 then return Duel.IsExistingMatchingCard(c86433607.scfilter,tp,LOCATION_DECK,0,1,nil) and req end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(c86433607.dfilter,1,nil) and check>1 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.floor(check/2))
	end
end
function c86433607.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c86433607.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==g:GetCount() then
			Duel.ConfirmCards(1-tp,g)
			local ct=Duel.GetMatchingGroupCount(c86433607.checksum,tp,0,LOCATION_MZONE,nil)
			if not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(c86433607.dfilter,1,nil) and ct>1 then
				Duel.Draw(tp,math.floor(ct/2),REASON_EFFECT)
			end
		end
	end
end

--target 2 cards
function c86433607.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c86433607.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c86433607.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c86433607.filter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,2,2,nil,tp)
	if g:GetClassCount(Card.GetCode)==1 then
		e:SetLabel(100)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	end
end
function c86433607.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==100 then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local sg=g:Filter(Card.IsRelateToEffect,nil,e)
		if sg:GetCount()>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rm=sg:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			if rm:GetCount()<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local th=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,rm:GetFirst())
			if th:GetCount()<=0 then return end
			Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
			Duel.SendtoHand(th,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,th)
		end
	else
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end