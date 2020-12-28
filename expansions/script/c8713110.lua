--Psycholucky
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--register
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(cid.regcon)
	e2:SetOperation(cid.regop)
	c:RegisterEffect(e2)
end
--Activate
function cid.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO) and c:IsAbleToHand()
		and (c.toss_coin or c.toss_dice)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO) and (c.toss_coin or c.toss_dice)
end
function cid.spfilter0(c,e,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(cid.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sg)
			if Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(cid.spfilter0,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,cid.spfilter0,tp,LOCATION_HAND,0,1,1,nil,e,tp)
				if #tg>0 then
					Duel.SpecialSummon(tg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end

--REGISTER
function cid.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO)
end
function cid.regcon(e,tp,eg,ep,ev,re,r,rp)
	local ex1=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	local ex2=Duel.GetOperationInfo(ev,CATEGORY_DICE)
	return (ex1 or ex2) and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_MZONE,0,1,nil)
end
function cid.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--dice effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TOSS_DICE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(3)
	e1:SetCondition(cid.dicecon)
	e1:SetOperation(cid.diceop)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN)
	c:RegisterEffect(e1)
	--coin effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TOSS_COIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.dicecon)
	e2:SetOperation(cid.coinop)
	e2:SetLabelObject(re)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN)
	c:RegisterEffect(e2)
end

--DICE EFFECT
function cid.dicecon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function cid.diceop(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAbleToRemove),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,0,id)
		local res={Duel.GetDiceResult()}
		if #res>1 then
			for i=1,#res do
				if res[i]==0 then
					table.remove(res,i)
				end
			end
			local ac=Duel.AnnounceNumber(tp,table.unpack(res))
			ct=ac
		else
			ct=res[1]
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsAbleToRemove),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				tc:SetTurnCounter(0)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
				e1:SetReset(RESET_PHASE+PHASE_STANDBY,ct)
				e1:SetLabel(ct)
				e1:SetLabelObject(tc)
				e1:SetCountLimit(1)
				e1:SetCondition(cid.turncon)
				e1:SetOperation(cid.turnop)
				Duel.RegisterEffect(e1,tp)
				local e2=e1:Clone()
				e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e2:SetCondition(cid.retcon)
				e2:SetOperation(cid.retop)
				Duel.RegisterEffect(e2,tp)
				tc:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_STANDBY,0,ct)
				local mt=_G["c"..tc:GetCode()]
				mt[tc]=e1
			end
		end
	end
end
function cid.turncon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(1082946)~=0
end
function cid.turnop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ct=tc:GetTurnCounter()
	ct=ct+1
	tc:SetTurnCounter(ct)
	if ct>e:GetLabel() then
		tc:ResetFlagEffect(1082946)
		e:Reset()
	end
end
function cid.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local ct=tc:GetTurnCounter()
	if ct==e:GetLabel() then
		return true
	end
	if ct>e:GetLabel() then
		e:Reset()
	end
	return false
end
function cid.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.ReturnToField(tc)
end

--COIN EFFECT
function cid.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cid.coinop(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	local res={Duel.GetCoinResult()}
	for i=1,ev do
		if res[i]==1 then
			ct=ct+1
		end
	end
	if ct<=0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<ct then return else ft=ct end
	if Duel.GetFlagEffect(tp,id)<=0 and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ft,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ft,ft,nil,e,tp)
		if #g==ft then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end