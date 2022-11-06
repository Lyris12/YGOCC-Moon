--Paladino Biancocchio
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
① When a monster(s) with a different Type from this card is Summoned: You can target 1 of those monsters; this card's Type becomes the Type of that target, also, if this card has 2500 or less ATK, it gains ATK equal to that target's current ATK.
② Once per turn, while this card has 2500 or more ATK, you can (Quick Effect): Until the end of the turn, this card cannot be destroyed or targeted by your opponent's card effects, also this card's ATK is halved at the end of the turn.
]]

function s.initial_effect(c)
	c:SummonedFieldTrigger(nil,false,true,true,true,0,{CATEGORY_ATKCHANGE,CATEGORY_UPDATE_RACE},EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE,nil,aux.EventGroupCond(s.cf),nil,s.target,s.operation)
	c:Quick(false,1,false,false,false,false,1,s.ptcon,nil,nil,s.ptop)
end
function s.cf(c,e)
	return c:IsFaceup() and c:IsMonster() and c:GetRace()~=e:GetHandler():GetRace()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.cf(chkc,e) end
	if chk==0 then return eg:IsExists(s.cf,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=eg:FilterSelect(tp,s.cf,1,1,nil,e)
	if #g>0 then
		Duel.SetTargetCard(g)
		Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_RACE,e:GetHandler(),1,0,0,g:GetFirst():GetRace())
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		c:ChangeRace(tc:GetRace(),true)
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:GetAttack()<=2500 then
			c:UpdateATK(tc:GetAttack(),true)
		end
	end
end

function s.ptcon(e)
	return e:GetHandler():IsAttackAbove(2500)
end
function s.ptop(e,tp)
	local c=e:GetHandler()
	if c and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:Desc(3)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		c:RegisterEffect(e1)
		--
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e3=Effect.CreateEffect(c)
		e3:Desc(2)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetCondition(s.atkcon)
		e3:SetOperation(s.atkop)
		Duel.RegisterEffect(e3,tp)
		c:CreateEffectRelation(e3)
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	if not c or c:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,PLAYER_ALL,id)
	local c=e:GetOwner()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:HalveATK(true)
	end
end