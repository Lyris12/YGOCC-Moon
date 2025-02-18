--[[
Blue-Eyes Zombie Dragon
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute Summon this card in Attack Position by Tributing 1 Zombie monster you control with 2500 or more ATK. 
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(id,0)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.otcon)
	e0:SetOperation(s.otop)
	e0:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e0)
	--[[At the end of the Battle Phase, if this card destroyed a monster(s) by battle and sent it to the GY: You can target 1 of those monsters; Special Summon it to your field in Attack Position, and
	if you do, it becomes a Zombie monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
--E0
function s.otfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup()) and c:IsRace(RACE_ZOMBIE) and c:IsAttackAbove(2500) 
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
end

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.filter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id+100) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	end
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,c,Duel.GetTurnCount())
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

--E2
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
end