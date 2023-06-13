--created & coded by Lyris, art from Shadowverse's "Cultivate Life"
--Hadoken Nurtration
local s,id,o=GetID()
if not s.global_check then
	s.global_check=true
	local f=Card.IsHadoken
	function Card.IsHadoken(c) return f and f(c) or c:IsCode(id) end
end
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
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<6 then return end
	local g=Group.CreateGroup()
	for i=0,5 do g:AddCard(Duel.GetFieldCard(tp,LOCATION_DECK,i)) end
	Duel.ConfirmCards(tp,g)
	while #g>0 do
		Duel.Hint(HINT_SELECTMSG,tp,205)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
		g:RemoveCard(tc)
	end
end
function s.val(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)//2*100
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local ct=0
	for i=0,2 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		for p=0,1 do Duel.ConfirmCards(p,tc,true) end
		if tc:IsHadoken() then ct=ct+1 end
	end
	local tg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,0,nil)
	if ct>0 and #tg>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=tg:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	for i=1,3 do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
