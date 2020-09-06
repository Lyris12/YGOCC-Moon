--SKILL: Ardente Disegnare
--Script by XGlitchy30 & Stormbreaker, fixed by somen00b, LP 3000 or less requirement added by somen00b
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--ED Skill Properties
    aux.EDSkillProperties(c)
    --Burning Draw
    local SKILL=Effect.CreateEffect(c)
    SKILL:SetType(EFFECT_TYPE_FIELD)
    SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
    SKILL:SetRange(LOCATION_EXTRA)
    SKILL:SetCode(EFFECT_SPSUMMON_PROC_G)
    SKILL:SetCondition(cid.skillcon)
    SKILL:SetOperation(cid.skillop)
    SKILL:SetValue(SUMMON_TYPE_SPECIAL+1)
    c:RegisterEffect(SKILL)
end
--filters
function cid.skillcon(e,c)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(99988871)>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.GetLP(tp)<=3000 and Duel.GetLP(tp)>=1100
end
--Burning Draw
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_CARD,0,id)
	local p1=Duel.GetLP(tp)-100
	local d=math.floor(p1/1000)
	Duel.SetLP(tp,100)
	Duel.Draw(tp,d,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,0,0,1)
end