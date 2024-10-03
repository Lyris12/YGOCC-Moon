--created by Slick, coded by Lyris
--Kronologistics Dicetron Prime
local s,id,o = GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,6)
	aux.AddCodeList(c,212111811)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ENGAGE)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.eucon)
	e1:SetTarget(s.eutg)
	e1:SetOperation(s.euop)
	c:RegisterEffect(e1)
	c:DriveEffect(0,aux.Stringid(id,0),0,EFFECT_TYPE_IGNITION,nil,nil,nil,nil,s.ectg,s.ecop)
	c:DriveEffect(-18,1124,CATEGORY_DESTROY,CATEGORY_DESTROY,EFFECT_TYPE_IGNITION,nil,nil,nil,nil,s.destg,s.desop)
	c:OverDriveEffect(c,1109,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,nil,nil,nil,nil,s.thtg,s.thop)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCondition(s.scon)
	e2:SetTarget(s.stg)
	e2:SetOperation(s.sop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.indcon)
	e3:SetTarget(s.indtg)
	e3:SetOperation(s.indop)
	c:RegisterEffect(e3)
end
s.toss_dice=true
function s.eucon(e,tp)
	return Duel.IsEnvironment(212111811,tp)
end
function s.eutg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:GetHandler():IsCanUpdateEnergy(1,tp,REASON_EFFECT,e) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.euop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		c:UpdateEnergy(Duel.TossDice(tp,1),tp,REASON_EFFECT,RESET_EVENT+RESETS_STANDARD,c,e)
	end
end
function s.ectg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:GetHandler():IsCanIncreaseOrDecreaseEnergy(1,tp,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.ecop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:IncreaseOrDecreaseEnergy(Duel.TossDice(tp,1),tp,REASON_EFFECT,RESET_EVENT+RESETS_STANDARD,c,e)
	end
end
function s.destg(e,tp,_,_,_,_,_,_,chk)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,ct)
end
function s.desop(e,tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=0
	for i=1,math.ceil(#g/5) do
		local t={Duel.TossDice(tp,math.min(5,#g%5))}
		for j=1,math.min(5,#g%5) do if t[j]>3 then ct=ct+1 end end
	end
	if ct>0 then Duel.BreakEffect() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,ct,ct,nil)
	Duel.HintSelection(sg)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.filter(c)
	return c:IsCode(212111811) and c:IsAbleToHand()
end
function s.thtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.scon(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE) and s.eucon(_,tp)
end
function s.sfilter(c,chk)
	if chk==nil then chk=true end
	return (c:IsCode(212111811) or aux.IsCodeListed(c,212111811) or chk and c:IsLevelBelow(4)
		and c:IsType(TYPE_DRIVE)) and c:IsAbleToHand()
end
function s.stg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,Duel.TossDice(tp,1)==4)
	Duel.BreakEffect()
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.indcon(e,tp)
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc:IsType(TYPE_DRIVE)
end
function s.indtg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetBattleMonster(tp):IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.indop(e,tp)
	local tc=Duel.GetBattleMonster(tp)
	if not (tc and tc:IsRelateToBattle()) then return end
	local chk=Duel.TossDice(tp,1)
	if chk~=1 and chk~=6 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
end
