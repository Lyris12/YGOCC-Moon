--Runecrafter's Paragon Rune
local id=80000811
local m=80000811
local cm=_G["c"..id]
local cid=_G["c"..id]

function cm.initial_effect(c)
	Auxiliary.I_Am_Paragon(c)
	Auxiliary.I_Am_Runic(c)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,8))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(3)
	e2:SetCondition(cm.condition)
	e2:SetOperation(cm.operation)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_EXTRA) 
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(cm.sdcon)
	e3:SetOperation(Auxiliary.sdop)
	c:RegisterEffect(e3)
end

function cid.sdcon(e,tp,eg,ep,ev,re,r,rp)
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	return ct1>=(ct2+3) 
end

function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id) ~= 1
end


function cm.operation(e,tp,eg,ep,ev,re,r,rp)

		Duel.Hint(HINT_CARD,0,id)
		Duel.AnnounceNumber(e:GetHandlerPlayer(),Duel.GetRP(e:GetHandlerPlayer()))
		cid.announce_filter={0x0ff5,OPCODE_ISSETCARD,0xfe0,OPCODE_ISSETCARD,OPCODE_AND}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
		card=Duel.CreateToken(tp,ac)
		local x = e:GetHandlerPlayer()
		local runpow = Duel.GetRP(x)
		if card:GetAttack() * 0.5 <= runpow then 
			Duel.Remove(card,POS_FACEUP,REASON_RULE)
			Duel.SendtoExtraP(card,tp,0,REASON_RULE)
			Duel.PayRPCost(tp,card:GetAttack() * 0.5)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+80808880,re,0,0,p,0)
		else if card:GetAttack() > runpow then
			Duel.Hint(HINT_MESSAGE,e:GetHandlerPlayer(),aux.Stringid(id,3))
			Duel.Exile(card,REASON_RULE)
			end
		end
end