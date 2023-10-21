--created & coded by Lyris, art from Shadowverse's "Cultivate Life"
--波動拳の培養
local s,id,o=GetID()
Card.IsHadoken=Card.IsHadoken or function(c) return c:GetCode()>102400019 and c:GetCode()<102400034 end
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local cf,cd=Duel.ConfirmCards,Duel.ConfirmDecktop
	function Duel.ConfirmCards(tp,g,xc)
		cf(tp,g)
		if not xc then return end
		if aux.GetValueType(g)=="Group" then
			for tc in aux.Next(g:Filter(Card.IsHadoken,nil)) do
				local p=tc:GetControler()
				if Duel.IsPlayerAffectedByEffect(p,id) then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
			end
		else
			local p=g:GetControler()
			if aux.GetValueType(g)=="Card" and g:IsHadoken() and Duel.IsPlayerAffectedByEffect(p,id) then
				Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
	function Duel.ConfirmDecktop(tp,ct)
		cd(tp,ct)
		if Duel.IsPlayerAffectedByEffect(tp,id) then
			for i=1,Duel.GetDecktopGroup(tp,ct):FilterCount(Card.IsHadoken,nil)*2 do
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			end
		end
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(id)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsHadoken))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>11 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<12 then return end
	local g=Group.CreateGroup()
	for i=0,11 do g:AddCard(Duel.GetFieldCard(tp,LOCATION_DECK,i)) end
	Duel.ConfirmCards(tp,g)
	while #g>0 do
		Duel.Hint(HINT_SELECTMSG,tp,205)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
		g:RemoveCard(tc)
	end
end
function s.val(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)//2*200
end
