--Insidiacelata Fossa
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only activate 1 "Hiddinsidia Pit" per turn.

① When you Normal or Flip Summon exactly 1 monster with 1500 or less ATK, you can activate this card from your hand.
② When exactly 1 monster is Normal or Flip Summoned: You can choose 1 occupied Monster Zone on the field; destroy the monster that occupies the chosen Zone, and if you do, if this card was Set before activation and the destroyed monster is now in the GY and it was in a Main Monster Zone, that Main Monster Zone cannot be used as long as the destroyed monster remains in the GY.
③ If this Set card in your Spells & Traps Zone is destroyed by an opponent's card effect and sent to the GY: You can choose 1 unused Main Monster Zone on the field. The first time a monster is Normal Summoned or Set in the chosen Zone, destroy that monster.
]]

function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCustomCategory(CATEGORY_ZONE+CATEGORY_DISABLE_ZONE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	--choose zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCustomCategory(CATEGORY_ZONE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end

--ACTIVATE
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	local occupied=0
	for tc in aux.Next(g) do
		local rzone = tc:IsControler(tp) and (1<<tc:GetSequence()) or (1<<(16+tc:GetSequence()))
		if tc:IsInEMZ() then
			rzone = rzone | (tc:IsControler(tp) and (1<<(16+11-tc:GetSequence())) or (1<<(11-tc:GetSequence())))
		end
		occupied = occupied|rzone
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local zone=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~occupied)
	Duel.Hint(HINT_ZONE,tp,zone)
	e:SetLabel(zone)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,zone,tp)
	if #sg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	end
	local pos = (e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetActivateLocation()&LOCATION_ONFIELD>0 and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
	if pos&POS_FACEDOWN>0 then
		Duel.SetCustomOperationInfo(0,CATEGORY_DISABLE_ZONE,nil,1,tp,zone)
	end
end
function s.filter(c,zone,tp)
	return aux.IsZone(c,zone,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pos=Duel.GetTargetParam()
	local zone=e:GetLabel()
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,zone,tp)
	if #sg>0 then
		local emzcheck = (not sg:GetFirst():IsInEMZ())
		if Duel.Destroy(sg,REASON_EFFECT)>0 and pos&POS_FACEDOWN>0 and emzcheck and sg:GetFirst():IsLocation(LOCATION_GRAVE) then
			sg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY+RESET_CONTROL,0,1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE_FIELD)
			e1:SetLabel(zone)
			e1:SetCondition(s.discon)
			e1:SetOperation(s.disop)
			e1:SetReset(0)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.discon(e)
	local g=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if g:IsExists(Card.HasFlagEffect,1,nil,id) then
		return true
	end
	e:Reset()
	return false
end
function s.disop(e)
	return e:GetLabel()
end

--CHOOSE ZONE
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and (r&0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN) and c:GetPreviousSequence()<5
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0
	end
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0x60)
	Duel.Hint(HINT_ZONE,tp,zone)
	e:SetLabel(zone)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	local p=tp
	local nseq=math.log(zone,2)
	if nseq>=16 then
		p=1-tp
		nseq=nseq-16
	end
	if not Duel.CheckLocation(p,LOCATION_MZONE,nseq) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(zone)
	e1:SetCondition(s.dscon)
	e1:SetOperation(s.dsop)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
	e2:SetLabelObject(e1)
end
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	return eg:IsExists(s.filter,1,nil,zone,tp)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabel()
	local g=eg:Filter(s.filter,nil,zone,tp)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Destroy(g,REASON_EFFECT)
		e:GetLabelObject():Reset()
		e:Reset()
	end
end

--ACT IN HAND
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAttackBelow(1500)
end
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	local event={EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS}
	for i=1,2 do
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(event[i],true)
		if res then
			return teg and #teg==1 and tep==tp and teg:IsExists(s.cfilter,1,nil)
		end
	end
end