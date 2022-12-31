--Steinitz's Juliet
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
--[[2 Spirit Monsters
Monsters this card points to cannot be destroyed by battle with monsters in a different column from them, also you take no battle damage from those battles. 
Spirit Monsters this card points to do not have to activate their effect during the End Phase. (Quick Effect): You can send 1 "Steinitz" Equip Card you control to the GY; 
Special Summon 1 "Steinitz" monster from your Deck with a different name than the sent one, in face-up Defense Position. 
You can only use this effect of "Steinitz's Juliet" once per turn.]]
local id,cod=ID()
function cod.initial_effect(c)
	--Link Summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_SPIRIT),2,2)
    c:EnableReviveLimit()
    --Indes
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(cod.indtg)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Damage Free
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(cod.damcon)
    e2:SetOperation(cod.damop)
    c:RegisterEffect(e2)
    --Do not return
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(cod.efftg)
    c:RegisterEffect(e3)
    --Special Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(cod.spcost)
    e4:SetTarget(cod.sptg)
    e4:SetOperation(cod.spop)
    c:RegisterEffect(e4)
end
function cod.indtg(e,c)
	local ac=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
    return e:GetHandler():GetLinkedGroup():IsContains(c) and not (c:GetColumnGroup():IsContains(ac) or c:GetColumnGroup():IsContains(dc))
end
function cod.damcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    local bc=tc:GetBattleTarget()
    return ep==tp and bc:IsSetCard(0x63d0) and e:GetHandler():GetLinkedGroup():IsContains(bc) and not bc:GetColumnGroup():IsContains(tc)
end
function cod.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChangeBattleDamage(ep,0)
end
function cod.efftg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function cod.cfilter(c,e,tp)
	return c:IsSetCard(0x63d0) and c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function cod.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cod.cfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SendtoGrave(g,REASON_EFFECT)
	e:SetLabel(g:GetFirst():GetCode())
end
function cod.spfilter(c,e,tp,code)
	return c:GetCode()~=code and c:IsSetCard(0x63d0) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function cod.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cod.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end