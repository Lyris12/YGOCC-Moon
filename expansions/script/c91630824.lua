--[[
Lich-Lord Baz'ri
Signore-Lich Baz'ri
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord Baz'ri".
	c:SetUniqueOnField(1,0,id)
	--[[During your Main Phase or your opponent's Battle Phase, if this card is in your hand or GY, and you have "Lich-Lord's Phylactery" in your GY (Quick Effect):
	You can Tribute 2 Zombie monsters on either field, including at least 1 from your field; Special Summon this card]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:HOPT()
	e2:SetFunctions(s.spcon,s.spcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
	if not s.effect_table then
		s.effect_table={}
	end
	s.effect_table[e2]=true
	--[[During your Standby Phase, if you do not have "Lich-Lord's Phylactery" in your GY: Destroy this card, and if you do,
	place 1 "Lich-Lord" Continuous Spell/Trap from your Deck or GY in your Spell/Trap Zone, face-up.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DESTROY|CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetFunctions(s.sdcon,nil,s.sdtg,s.sdop)
	c:RegisterEffect(e3)
	--[[While you have "Lich-Lord's Phylactery" in your GY, change all "Lich-Lord" monsters you control to Attack Position, also they gain ATK equal to their DEF, but cannot attack directly.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(aux.PhylacteryCondition)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_LICH_LORD))
	e4:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetTarget(s.atktg)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	if not s.global_check then
		s[0]=false
		s[1]=false
		s.global_check=true
		local ge=Effect.CreateEffect(c)
		ge:SetDescription(aux.Stringid(id,2))
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
		ge:SetAbsoluteRange(0,0,LOCATION_MZONE)
		ge:SetCondition(s.relcon(0))
		ge:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
		ge:SetValue(s.relval)
		Duel.RegisterEffect(ge,0)
		local ge2=ge:Clone()
		ge2:SetAbsoluteRange(1,0,LOCATION_MZONE)
		ge2:SetCondition(s.relcon(1))
		Duel.RegisterEffect(ge2,1)
	end
end
function s.relcon(p)
	return	function(e)
				return s[p]==true
			end
end
function s.relval(e,re,r,rp)
	return r&REASON_COST==REASON_COST and re and s.effect_table[re]==true
end

--E2
function s.scfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(id) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsMainPhase(tp) or Duel.IsBattlePhase(1-tp)) and aux.PhylacteryCheck(tp)
end
function s.costfilter(c,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	return c:IsControler(tp) or c:IsFaceup()
end
function s.gcheck(g,tp)
	return g:IsExists(Card.IsControler,1,nil,tp) and Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local temp=s[tp]
	s[tp]=true
	local g=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil,tp)
	if chk==0 then
		local res=g:CheckSubGroup(s.gcheck,2,2,tp)
		s[tp]=temp
		return res
	end
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	Duel.Release(sg,REASON_COST)
	s[tp]=temp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and not aux.PhylacteryCheck(tp)
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	Duel.SetCardOperationInfo(c,CATEGORY_DESTROY)
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:IsST(TYPE_CONTINUOUS) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local g=Duel.Select(HINTMSG_TOFIELD,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp)
		if #g>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end

--E4
function s.atktg(e,c)
	return c:IsSetCard(ARCHE_LICH_LORD) and c:HasDefense()
end
function s.atkval(e,c)
	return c:GetDefense()
end