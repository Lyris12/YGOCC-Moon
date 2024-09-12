--Anbionic Prototype Test
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon a number of "Spindown Tokens" (Thunder/LIGHT/Level 1/0 ATK/1000 DEF) in Defense Position, up to the number of "Anbionic" Spells/Traps with different names you control and/or in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xe57) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--also you cannot Special Summon monsters from your Extra Deck for the rest of this turn, except "Anbionic" monsters.
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(s.splimit)
	Duel.RegisterEffect(e3,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,e)
	local ct=g:GetClassCount(Card.GetCode)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,177222704,0,TYPES_TOKEN_MONSTER,0,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT) then return end
	local ctn=true
	while ft>0 and ctn do
		local tk=Duel.CreateToken(tp,177222704)
		Duel.SpecialSummonStep(tk,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DESTROYED)
		e1:SetCondition(s.drawcon)
		e1:SetOperation(s.drawop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DESTROY)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.checkop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tk:RegisterEffect(e2)
		tk:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		ft=ft-1
		if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then ctn=false end
	end
	Duel.SpecialSummonComplete()
end
function s.splimit(e,c)
	return not c:IsSetCard(0xe57) and c:IsLocation(LOCATION_EXTRA)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=e:GetLabelObject()
	e1:SetLabel(1)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	e:SetLabel(0)
	e:Reset()
end