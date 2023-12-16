--Radiant Summoner Knight LV8
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249000105.initial_effect(c)
	c:EnableReviveLimit()
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--special summon create
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(509)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c249000105.target)
	e2:SetOperation(c249000105.operation)
	c:RegisterEffect(e2)
	--cannot special summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
end
c249000105.lvdncount=2
c249000105.lvdn={249000103,249000104}
c249000105.summonable_code_table={249000105,OPCODE_ISCODE,249000106,OPCODE_ISCODE,OPCODE_OR,249000107,OPCODE_ISCODE,OPCODE_OR,249000109,OPCODE_ISCODE,OPCODE_OR,249000110,OPCODE_ISCODE,OPCODE_OR,
249000108,OPCODE_ISCODE,OPCODE_OR,249000111,OPCODE_ISCODE,OPCODE_OR}
function c249000105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c249000105.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCardFilter(tp,table.unpack(c249000105.summonable_code_table))
		if ac==249000105 then return end
		cc=Duel.CreateToken(tp,ac)
	until cc:IsCanBeSpecialSummoned(e,0,tp,true,false) and not banned_list_table[ac]
	if Duel.SpecialSummonStep(cc,0,tp,tp,true,false,POS_FACEUP) then
		aux.CannotBeEDMaterial(cc,nil,LOCATION_MZONE,true,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		cc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end