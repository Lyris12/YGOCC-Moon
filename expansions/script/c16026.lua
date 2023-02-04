--Paracyclis Counterswipe

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.filter)
	--activate from hand condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end

function s.tgfilter(c)
	return c:IsSetCard(0x308) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_COST|REASON_DISCARD,nil)
end
function s.egfilter(c,tp,mode)
	if c:GetSummonPlayer()~=1-tp then return false end
	if (not mode or mode==0) and not c:IsType(TYPE_LINK) then
		return c:IsCanTurnSetGlitchy(tp) and Duel.IsPlayerCanDraw(tp,1)	
	elseif (not mode or mode==1) and c:IsType(TYPE_LINK) then
		return c:IsAbleToGrave()
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.egfilter,nil,tp)
	if chk==0 then
		e:SetCategory(0)
		return #g>0
	end
	e:SetCategory(0)
	local b1=g:IsExists(s.egfilter,1,nil,tp,0)
	local b2=g:IsExists(s.egfilter,1,nil,tp,1)
	local opt=aux.Option(id,tp,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW)
		local og=eg:Filter(Card.IsCanTurnSetGlitchy,nil,tp)
		local player
		for p=tp,1-tp,1-2*tp do
			if og:IsExists(Card.IsControler,1,nil,p) then
				if not player then
					player=p
				else
					player=PLAYER_ALL
				end
			end
		end
		Duel.SetOperationInfo(0,CATEGORY_POSITION,og,#og,player,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		
	elseif opt==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		local og=eg:Filter(Card.IsAbleToGrave,nil)
		local player
		for p=tp,1-tp,1-2*tp do
			if og:IsExists(Card.IsControler,1,nil,p) then
				if not player then
					player=p
				else
					player=PLAYER_ALL
				end
			end
		end
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,og,#og,player,LOCATION_MZONE)
	end
	Duel.SetTargetCard(eg)
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		local opt=e:GetLabel()
		if opt==0 then
			local og=g:Filter(Card.IsCanTurnSetGlitchy,nil,tp)
			if Duel.ChangePosition(og,POS_FACEDOWN_DEFENSE)~=0 and og:IsExists(Card.IsPosition,1,nil,POS_FACEDOWN_DEFENSE) then
				if Duel.IsPlayerCanDraw(tp,1) then
					Duel.BreakEffect()
				end
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		
		elseif opt==1 then
			local og=g:Filter(Card.IsAbleToGrave,nil)
			Duel.SendtoGrave(og,REASON_EFFECT)
			local c=e:GetHandler()
			for tc in aux.Next(g) do
				local zone
				if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) then
					zone=tc:GetZone(tp)
				else
					zone=tc:GetPreviousZone(tp)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_MUST_USE_MZONE)
				e1:SetTargetRange(0xff,0xff)
				e1:SetLabel(tp)
				e1:SetValue(s.frcval({tc:GetCode()},zone))
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.frcval(codes,zone)
	return function(e,c,fp,rp,r)
		if rp==1-e:GetLabel() and c:IsCode(table.unpack(codes)) and r&LOCATION_REASON_TOFIELD==LOCATION_REASON_TOFIELD then
			return ~zone	
		else
			return ~zone|zone
		end
	end
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return #Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)<#Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
end
