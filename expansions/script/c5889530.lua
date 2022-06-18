--Groundhoard Whistlecall
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetRange(LOCATION_HAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drawcon)
	e1:SetCost(s.drawcost)
	e1:SetTarget(s.drawtg)
	e1:SetOperation(s.drawop)
	c:RegisterEffect(e1)
	--disable zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.zncost)
	e2:SetTarget(s.zntg)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_BEAST)
end
--SEARCH
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:IsExists(s.filter,1,nil) and not eg:IsContains(e:GetHandler())
end
function s.filter(c)
	return c:IsRace(RACE_BEAST) and not c:IsPublic()
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil):Filter(Card.IsLocation,nil,LOCATION_HAND)
	if chk==0 then return not e:GetHandler():IsPublic() and #g>0 end
	g:AddCard(e:GetHandler())
	g:KeepAlive()
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(g)
end
function s.thfilter(c,g)
	if not c:IsType(TYPE_MONSTER) or not c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_BEAST) or not c:IsAbleToHand() or g:IsExists(Card.IsAttribute,1,nil,c:GetAttribute()) then return false end
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
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil):Filter(Card.IsLocation,nil,LOCATION_HAND)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,g) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,sg)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	sg:DeleteGroup()
end

--DISABLE ZONE
function s.zncost(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.pcfilter(c,e,tp,ct)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEAST) and ((c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or not c:IsForbidden() and ct>0)
end
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)>0 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,ct) end
	local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler(),e,tp,ct)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)>0 then
		local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,EXTRA_MONSTER_ZONE)
		zone=(~dis)
		Duel.Hint(HINT_ZONE,tp,dis)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabel(dis)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pcfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp,Duel.GetLocationCount(tp,LOCATION_SZONE))
	if #g>0 then	
		local tc=g:GetFirst()
		local b1=(tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		local b2=(not tc:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		local op=0
		if not tc or (not b1 and not b2) then return end
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
		end
		if op==0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
		elseif op==1 and not g:GetFirst():IsImmuneToEffect(e) and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end