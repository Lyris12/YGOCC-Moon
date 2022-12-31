--Groundhoard Communion
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_BEAST)
end
--ACTIVATE
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not s.counterfilter(c)
end
function s.thfilter(c,attr)
	if not c:IsType(TYPE_MONSTER) or not c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_BEAST) or not c:IsAbleToHand() or (attr and c:IsAttribute(attr)) then return false end
	local egroup=global_card_effect_table[c]
	for i=1,#egroup do
		local ce=egroup[i]
		if ce and aux.GetValueType(ce)=="Effect" and ce.SetLabelObject then
			local cat,flag=ce:GetCustomCategory()
			if cat&CATEGORY_PLACE_AS_CONTINUOUS_TRAP>0 and flag&CATEGORY_FLAG_SELF>0 then
				return true
			end
		end
	end
	return false
end
function s.thfilter2(c,tp)
	if not c:IsType(TYPE_MONSTER) or not c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_BEAST) or not c:IsAbleToHand() or not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetAttribute()) then return false end
	local egroup=global_card_effect_table[c]
	for i=1,#egroup do
		local ce=egroup[i]
		if ce and aux.GetValueType(ce)=="Effect" and ce.SetLabelObject then
			local cat,flag=ce:GetCustomCategory()
			if cat&CATEGORY_PLACE_AS_CONTINUOUS_TRAP>0 and flag&CATEGORY_FLAG_SELF>0 then
				return true
			end
		end
	end
	return false
end
function s.pcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and not c:IsForbidden()
end
function s.chkfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_SZONE) and c:GetType()&0x20004==0x20004 and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-c:GetSequence()) --and not Duel.GetFieldGroup(tp,0,LOCATION_MZONE):IsExists(s.zcheck,1,nil,c:GetSequence(),tp)
end
function s.zcheck(c,i,tp)
	local zone=0x1<<(-i+20)
	return aux.IsZone(c,zone,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil))
	local b2=(ct>0 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()))
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(s.thop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetProperty(0)
		e:SetOperation(s.pcop)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
	local check=0
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)
	if ct>0 then
		local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE)
		check=check+1
		if ct>1 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			dis=dis|Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE|dis)
			check=check+1
		end
		Duel.Hint(HINT_ZONE,tp,dis)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabel(dis)
		Duel.RegisterEffect(e1,tp)
		if check>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if check>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,g,g:GetFirst():GetAttribute())
				g:Merge(g2)
			end
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_HAND,0,1,ct,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			if not tc:IsImmuneToEffect(e) and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
			tc=g:GetNext()
		end
	end
	local sg=g:Filter(s.chkfilter,nil,tp)
	if #sg>0 then
		local zone=0
		for tc in aux.Next(sg) do
			local i=tc:GetSequence()
			zone=zone|(0x1<<(20-i))
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabel(zone)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end

--DRAW
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and c:IsAbleToDeck()
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg<=0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end