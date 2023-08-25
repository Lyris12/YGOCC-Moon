--Bigbang Climber
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,Card.IsPositive,1,1,Card.IsNegative,1,1)
	--If this card is Bigbang Summoned: You can Special Summon 1 "Positive Token" (Rock/EARTH/Level 4/ATK 2000/DEF 1000), and 1 "Negative Token" (Rock/EARTH/Level 4/ATK 1000/DEF 2000),
	--but destroy them during the End Phase, also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Bigbang Monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,177222572,0,TYPES_TOKEN_MONSTER,2000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,177222573,0,TYPES_TOKEN_MONSTER,1000,2000,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,177222572,0,TYPES_TOKEN_MONSTER,2000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,177222573,0,TYPES_TOKEN_MONSTER,1000,2000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	local fid=e:GetHandler():GetFieldID()
	local token=Duel.CreateToken(tp,177222572)
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	local token2=Duel.CreateToken(tp,177222573)
	Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
	token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	token2:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	Duel.SpecialSummonComplete()
	sg=Group.FromCards(token,token2)
	sg:KeepAlive()
	--but destroy them during the End Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(sg)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	Duel.RegisterEffect(e1,tp)
	--also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Bigbang Monsters.
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_BIGBANG) and c:IsLocation(LOCATION_EXTRA)
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end
