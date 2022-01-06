--RATatool
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(cid.setcost)
	e2:SetTarget(cid.settg)
	e2:SetOperation(cid.setop)
	c:RegisterEffect(e2)
end
--ACTIVATE
function cid.filter(c,tp,ct,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:GetLevel()>0 and c:GetLevel()~=1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=(c:GetLevel()+ct-1)
		and (not e or c:IsCanBeEffectTarget(e))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,0,nil) end
	local g=Group.CreateGroup()
	local d=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local ct=0
	while #g<=2 and Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,ct,nil) do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g1=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,(ct==0) and 1 or 0,1,nil,tp,ct,e)
		g:Merge(g1)
		ct=ct+g1:GetFirst():GetLevel()-1
	end
	if #g==0 then return end
	Duel.SetTargetCard(g)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local ct,check=0,0
	while tc do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsLevel(1) then
			ct=ct+tc:GetLevel()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:IsLevel(1) then check=check+1 end
		end
		tc=g:GetNext()
	end
	local count=ct-#g
	if count<=0 then return end
	if check==#g and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=count then
		Duel.ConfirmDecktop(tp,count)
		local dg=Duel.GetDecktopGroup(tp,count)
		if #dg>0 then
			Duel.DisableShuffleCheck()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92362073,2))
			local sg=dg:Select(tp,1,1,nil):GetFirst()
			Duel.MoveSequence(sg,1)
			Duel.SortDecktop(tp,tp,count-1)
			if count~=1 then
				for i=1,count-1 do
					local mg=Duel.GetDecktopGroup(tp,1)
					Duel.MoveSequence(mg:GetFirst(),1)
				end
			end
			Duel.MoveSequence(sg,0)
		end
	end
end

--SET
function cid.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.setfilter(c)
	return c:IsCode(id-1) and c:IsSSetable()
end
function cid.ratfilter(c)
	return c:IsFaceup() and c:IsCode(55935416)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 and Duel.IsExistingMatchingCard(cid.ratfilter,tp,LOCATION_MZONE,0,1,nil) then
		if tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if tc:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end