--Rune Anvil
local id=80808880
local m=80808880
local cm=_G["c"..id]
local cid=_G["c"..id]
function cm.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1)
	e0:SetOperation(cm.start)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,2))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCost(cm.cost2)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,8))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.condition)
	e2:SetTarget(cm.target2)
	e2:SetOperation(cm.operation2)
	c:RegisterEffect(e2)

	local RUNEC=Effect.CreateEffect(c)
	RUNEC:SetDescription(aux.Stringid(m,1))
	RUNEC:SetType(EFFECT_TYPE_FIELD)
	RUNEC:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	RUNEC:SetRange(LOCATION_EXTRA)
	RUNEC:SetCode(EFFECT_SPSUMMON_PROC_G)
	RUNEC:SetOperation(cid.skillop)
	RUNEC:SetValue(SUMMON_TYPE_SPECIAL+1)
	c:RegisterEffect(RUNEC)
end



function cm.start(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetOwner()
	if Duel.GetFlagEffect(tp,id) == 0 then
		Duel.RegisterFlagEffect(tp,id,RESET_DISABLE,0,1)
		Duel.Remove(c,tp,REASON_EFFECT)
		Duel.SendtoExtraP(c,tp,REASON_EFFECT)
	end
	if Duel.GetFlagEffectLabel(tp,id) == 0 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
			Duel.GainRP(tp,100000)
			Duel.SetFlagEffectLabel(tp,id,2)
		end
	end
	if Duel.GetFlagEffectLabel(tp,id) == 0 then
		Duel.SetFlagEffectLabel(tp,id,1)
	end
	Duel.GainRP(tp,200)
end

function cm.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRPCost(tp,1000) end
	Duel.PayRPCost(tp,1000)
end

function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)) do
		Duel.HintSelection(Group.FromCards(tc))
		tc:AddRuneslots(1)
	end
end

function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffectLabel(tp,id) == 2
end


function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,99,nil)
end

function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,8)) then
		for tc in aux.Next(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)) do
			Duel.HintSelection(Group.FromCards(tc))
			local t={}
			for i=1,12 do table.insert(t,i) end
			tc:AddRuneslots(Duel.AnnounceNumber(tp,table.unpack(t)))
		end
	end
end


function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	local num = Duel.SelectOption(e:GetHandlerPlayer(),aux.Stringid(id,4),aux.Stringid(id,5),aux.Stringid(id,6))
	
	if (num == 0) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.AnnounceNumber(e:GetHandlerPlayer(),Duel.GetRP(e:GetHandlerPlayer()))
		cid.announce_filter={0x1ff5,OPCODE_ISSETCARD}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
		card=Duel.CreateToken(tp,ac)
		local x = e:GetHandlerPlayer()
		local runpow = Duel.GetRP(x)
		if card:GetAttack() <= runpow then 
			Duel.Remove(card,POS_FACEUP,REASON_RULE)
			Duel.SendtoExtraP(card,tp,0,REASON_RULE)
			Duel.PayRPCost(tp,card:GetAttack())
		else if card:GetAttack() > runpow then
			Duel.Hint(HINT_MESSAGE,e:GetHandlerPlayer(),aux.Stringid(m,3))
			Duel.Exile(card,REASON_RULE)
			end
		end
	end

	if (num == 1) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.AnnounceNumber(e:GetHandlerPlayer(),Duel.GetRP(e:GetHandlerPlayer()))
		cid.announce_filter={0x2ff5,OPCODE_ISSETCARD}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
		card=Duel.CreateToken(tp,ac)
		local x = e:GetHandlerPlayer()
		local runpow = Duel.GetRP(x)
		if card:GetAttack() <= runpow then 
			Duel.Remove(card,POS_FACEUP,REASON_RULE)
			Duel.SendtoExtraP(card,tp,0,REASON_RULE)
			Duel.PayRPCost(tp,card:GetAttack())
		else if card:GetAttack() > runpow then
			Duel.Hint(HINT_MESSAGE,e:GetHandlerPlayer(),aux.Stringid(m,3))
			Duel.Exile(card,REASON_RULE)
			end
		end
	end

	if (num == 2) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.AnnounceNumber(e:GetHandlerPlayer(),Duel.GetRP(e:GetHandlerPlayer()))
		cid.announce_filter={0x4ff5,OPCODE_ISSETCARD}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
		card=Duel.CreateToken(tp,ac)
		local x = e:GetHandlerPlayer()
		local runpow = Duel.GetRP(x)
		if card:GetAttack() <= runpow then 
			Duel.Remove(card,POS_FACEUP,REASON_RULE)
			Duel.SendtoExtraP(card,tp,0,REASON_RULE)
			Duel.PayRPCost(tp,card:GetAttack())
		else if card:GetAttack() > runpow then
			Duel.Hint(HINT_MESSAGE,e:GetHandlerPlayer(),aux.Stringid(m,3))
			Duel.Exile(card,REASON_RULE)
			end
		end
	end
end