--Unknown name
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	c:SetUniqueOnField(1,0,s_id)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:GetCode()>30200 and tc:GetCode()<30230 end)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(scard.drawop)
	c:RegisterEffect(e2)
end
function scard.drawop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(scard.drawfilter,1,nil,tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_CHAIN)
		e1:SetOperation(scard.drawdrawop)
		e:GetHandler():RegisterEffect(e1,true)
		local g=eg:Filter(scard.drawfilter,nil,tp)
		g:KeepAlive()
		e1:SetLabelObject(g)
		e1:SetLabel(Duel.GetCurrentChain())
	end
end
function scard.drawdrawop(e,tp)
	if Duel.GetCurrentChain()==e:GetLabel() then
		local g=e:GetLabelObject()
		Duel.Draw(tp,g:GetCount(),REASON_EFFECT)
		g:DeleteGroup()
	end
end
function scard.drawfilter(c,tp)
	return c:GetPreviousLocation()==LOCATION_HAND and c:GetPreviousControler()==tp and c:IsType(TYPE_MONSTER) and c:IsMantra()
	and bit.bor(c:GetReason(),REASON_COST+REASON_EFFECT)~=0
end
